use std::ops::RangeInclusive;

#[derive(Debug, PartialEq)]
struct PasswordPolicy {
	byte: u8,
	range: RangeInclusive<usize>,
}

fn parse_line(s: &str) -> anyhow::Result<(PasswordPolicy, &str)> {
	peg::parser! {
      grammar parser() for str {
        rule number() -> usize
          = n:$(['0'..='9']+) { n.parse().unwrap() }

        rule range() -> RangeInclusive<usize>
          = min:number() "-" max:number() { min..=max }

        rule byte() -> u8
          = letter:$(['a'..='z']) { letter.as_bytes()[0] }

        rule password() -> &'input str
          = letters:$([_]*) { letters }

        pub(crate) rule line() -> (PasswordPolicy, &'input str)
          = range:range() " " byte:byte() ": " password:password() {
              (PasswordPolicy { range, byte }, password)
          }
      }
    }

    Ok(parser::line(s)?)
}

impl PasswordPolicy {
	fn is_valid(&self, password: &str) -> bool {
		self.range.contains(
			&password
				.as_bytes()
				.iter()
				.copied()
				.filter(|&b| b == self.byte)
				.count(),
		)
	}
}

#[derive(Debug, PartialEq)]
struct PasswordPolicy2 {
	byte: u8,
	positions: [usize; 2],
}

fn parse_line2(s: &str) -> anyhow::Result<(PasswordPolicy2, &str)> {
	peg::parser! {
      grammar parser() for str {
        rule number() -> usize
          = n:$(['0'..='9']+) { n.parse().unwrap() }

        rule positions() -> [usize; 2]
          = first:number() "-" second:number() { [first-1, second-1] }

        rule byte() -> u8
          = letter:$(['a'..='z']) { letter.as_bytes()[0] }

        rule password() -> &'input str
          = letters:$([_]*) { letters }

        pub(crate) rule line() -> (PasswordPolicy2, &'input str)
          = positions:positions() " " byte:byte() ": " password:password() {
              (PasswordPolicy2 { positions, byte }, password)
          }
      }
    }

    Ok(parser::line(s)?)
}

impl PasswordPolicy2 {
	fn is_valid(&self, password: &str) -> bool {
		self.positions
			.iter()
			.copied()
			.filter(|&index| password.as_bytes()[index] == self.byte)
			.count()
			== 1
	}
}
fn main() -> anyhow::Result<()> {
	// p1
    let count = include_str!("input.txt")
    	.lines()
    	.map(parse_line)
    	.map(Result::unwrap)
    	.filter(|(policy, password)| policy.is_valid(password))
    	.count();

    println!("{} passwords are valid", count);

    // p2
	let count = include_str!("input.txt")
    	.lines()
    	.map(parse_line2)
    	.map(Result::unwrap)
    	.filter(|(policy, password)| policy.is_valid(password))
    	.count();

    println!("{} passwords are valid", count);

    Ok(())
}

#[cfg(test)]
mod tests {
	use super::PasswordPolicy;
	use super::parse_line;
	use super::PasswordPolicy2;
	use super::parse_line2;

	#[test]
	fn test_is_valid() {
		let pp = PasswordPolicy {
			range: 1..=3,
			byte: b'a',
		};
		assert_eq!(pp.is_valid("zers"), false);
		assert_eq!(pp.is_valid("hate"), true);
		assert_eq!(pp.is_valid("haaat"), true);
		assert_eq!(pp.is_valid("haaaaaaaat"), false);
	}

	#[test]
	fn test_parse_line() {
		assert_eq!(
			parse_line("1-3 a: banana").unwrap(),
			(
				PasswordPolicy {
					range: 1..=3,
					byte: b'a',
				},
				"banana",
			)
		);
	}

	#[test]
	fn test_is_valid2() {
		let pp = PasswordPolicy2 {
			positions: [0, 2],
			byte: b'a',
		};
		assert_eq!(pp.is_valid("zers"), false);
		assert_eq!(pp.is_valid("ate"), true);
		assert_eq!(pp.is_valid("tea"), true);
		assert_eq!(pp.is_valid("ata"), false);
	}

	#[test]
	fn test_parse_line2() {
		assert_eq!(
			parse_line2("1-3 a: banana").unwrap(),
			(
				PasswordPolicy2 {
					positions: [0, 2],
					byte: b'a',
				},
				"banana",
			)
		);
	}
}

