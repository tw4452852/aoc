use std::ops::RangeInclusive;

fn main() {
	let input = include_str!("input.txt");

	// p1
	let results = input.split("\n\n")
		.map(PassportBuilder::parse)
		.map(PassportBuilder::build);
	let num_field = results.filter(Result::is_ok).count();
	dbg!(num_field);

	// p2
	let results = input.split("\n\n")
		.map(|lines| PassportBuilder::parse2(lines).and_then(|b| b.build()));
	let num_valid = results.filter(Result::is_ok).count();
	dbg!(num_valid);
}

#[derive(Clone, Copy, PartialEq, Debug)]
struct Year(u64);

#[derive(Clone, Copy, PartialEq, Debug)]
enum Length {
    Cm(u64),
    In(u64),
    Unspecified(u64),
}

#[derive(Clone, Copy, PartialEq, Debug)]
struct Color<'a>(&'a str);

#[derive(Clone, Copy, PartialEq, Debug)]
struct ID<'a>(&'a str);

#[derive(PartialEq, Debug)]
struct Passport<'a> {
    birth_year: Year,
    issue_year: Year,
    expiration_year: Year,
    height: Length,
    hair_color: Color<'a>,
    eye_color: Color<'a>,
    passport_id: ID<'a>,
    country_id: Option<ID<'a>>,
}

#[derive(PartialEq, Debug, Default)]
struct PassportBuilder<'a> {
    birth_year: Option<Year>,
    issue_year: Option<Year>,
    expiration_year: Option<Year>,
    height: Option<Length>,
    hair_color: Option<Color<'a>>,
    eye_color: Option<Color<'a>>,
    passport_id: Option<ID<'a>>,
    country_id: Option<ID<'a>>,
}

#[derive(thiserror::Error, Debug)]
enum Error {
    #[error("missing field: {0}")]
    MissingField(&'static str),

    #[error("could not parse {0}: {1}")]
    ParseErr(String, String),
}

impl<'a> PassportBuilder<'a> {
    fn build(self) -> Result<Passport<'a>, Error> {
        macro_rules! build {
			(
				required => {
					$($req: ident),* $(,)*
				}$(,)*
				optional => {
					$($opt: ident),* $(,)*
				}$(,)*
			) => {
				Ok(Passport {
					$($req: self.$req.ok_or(Error::MissingField(stringify!($req)))?),*,
					$($opt: self.$opt),*
				})
			}
		}

        build! {
            required => {
                birth_year,
                issue_year,
                expiration_year,
                height,
                hair_color,
                eye_color,
                passport_id,
            },
            optional => {
                country_id,
            },
        }
    }

    fn parse2(input: &'a str) -> Result<Self, Error> {
        let mut b: Self = Default::default();

        peg::parser! {
           grammar parser2() for str {
               pub(crate) rule root(b: &mut PassportBuilder<'input>)
                   = (field(b) separator()*)* ![_]

               rule separator()
                   = ['\n' | ' ']

               rule field(b: &mut PassportBuilder<'input>)
                   = byr(b) / iyr(b) / eyr(b) / hgt(b) / hcl(b) / ecl(b) / pid(b) / cid(b)

              	rule byr(b: &mut PassportBuilder<'input>)
                    = "byr:" year:year((1920..=2002)) { b.birth_year = Some(year); }

                rule iyr(b: &mut PassportBuilder<'input>)
                    = "iyr:" year:year((2010..=2020)) { b.issue_year = Some(year); }

                rule eyr(b: &mut PassportBuilder<'input>)
                    = "eyr:" year:year((2020..=2030)) { b.expiration_year = Some(year); }

               rule hgt(b: &mut PassportBuilder<'input>)
                    = "hgt:" height:length() {?
                        match &height {
                            Length::Cm(v) if !(150..=193).contains(v) => {
                                Err("bad height (cm)")
                            },
                            Length::In(v) if !(59..=76).contains(v) => {
                                Err("bad height (in)")
                            },
                            _ => {
                                b.height = Some(height);
                                Ok(())
                            },
                        }
                    }

               rule pid(b: &mut PassportBuilder<'input>)
                   = "pid:" id:$(['0'..='9']*<9,9>) { b.passport_id = Some(ID(id)) }

               rule cid(b: &mut PassportBuilder<'input>)
                   = "cid:" id:$((!separator()[_])+) { b.country_id = Some(ID(id)) }

               rule hcl(b: &mut PassportBuilder<'input>)
                   = "hcl:" color:hcl0() { b.hair_color = Some(color) }

               rule hcl0() -> Color<'input>
               	   = s:$("#" ['0'..='9' | 'a'..='f']*<6, 6>) { Color(s) }

               rule ecl(b: &mut PassportBuilder<'input>)
                   = "ecl:" color:ecl0() { b.eye_color = Some(color) }

               rule ecl0() -> Color<'input>
               	   = s:$("amb" / "blu" / "brn" / "gry" / "grn" / "hzl" / "oth") { Color(s) }

               rule year(range: RangeInclusive<u64>) -> Year
                    = num:num() {?
                        if range.contains(&num) {
                            Ok(Year(num))
                        } else {
                            Err("year out of range")
                        }
                    }

               rule length() -> Length
                   = num:num() "cm" { Length::Cm(num) }
                   / num:num() "in" { Length::In(num) }


               rule num() -> u64
                    = s:$(['0'..='9']+) { s.parse().unwrap() }

           }
        }

        parser2::root(input, &mut b).map_err(|e| Error::ParseErr(input.into(), e.to_string()))?;
        Ok(b)
    }

    fn parse(input: &'a str) -> Self {
        let mut b: Self = Default::default();

        peg::parser! {
           grammar parser() for str {
               pub(crate) rule root(b: &mut PassportBuilder<'input>)
                   = (field(b) separator()*)* ![_]

               rule separator()
                   = ['\n' | ' ']

               rule field(b: &mut PassportBuilder<'input>)
                    // years
                    = byr(b) / iyr(b) / eyr(b)
                    // height
                    / hgt(b)
                    // colors
                    / hcl(b) / ecl(b)
                    // IDs
                    / pid(b) / cid(b)

                rule byr(b: &mut PassportBuilder<'input>)
                    = "byr:" year:year() { b.birth_year = Some(year) }

                rule iyr(b: &mut PassportBuilder<'input>)
                    = "iyr:" year:year() { b.issue_year = Some(year) }

                rule eyr(b: &mut PassportBuilder<'input>)
                    = "eyr:" year:year() { b.expiration_year = Some(year) }

                rule hgt(b: &mut PassportBuilder<'input>)
                    = "hgt:" height:length() { b.height = Some(height) }

                rule pid(b: &mut PassportBuilder<'input>)
                    = "pid:" id:id() { b.passport_id = Some(id) }

                rule cid(b: &mut PassportBuilder<'input>)
                    = "cid:" id:id() { b.country_id = Some(id) }

                rule hcl(b: &mut PassportBuilder<'input>)
                    = "hcl:" color:color() { b.hair_color = Some(color) }

                rule ecl(b: &mut PassportBuilder<'input>)
                    = "ecl:" color:color() { b.eye_color = Some(color) }

                rule year() -> Year
                    = num:num() { Year(num) }

                rule color() -> Color<'input>
                    = s:$((!separator()[_])*) { Color(s) }

                rule length() -> Length
                    = num:num() "cm" { Length::Cm(num) }
                    / num:num() "in" { Length::In(num) }
                    / num:num() { Length::Unspecified(num) }

                rule num() -> u64
                    = s:$(['0'..='9']+) { s.parse().unwrap() }

                rule id() -> ID<'input>
                    = s:$(['0'..='9' | 'a'..='z' | '#']+)  { ID(s) }
           }
        }
        parser::root(input, &mut b).unwrap_or_else(|e| panic!("Could not parse {}: {}", input, e));
        b
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_builder() {
        assert!(PassportBuilder {
            ..Default::default()
        }
        .build()
        .is_err());
        assert!(PassportBuilder {
            birth_year: Some(Year(2014)),
            issue_year: Some(Year(2017)),
            expiration_year: Some(Year(2023)),
            height: Some(Length::Cm(195)),
            hair_color: Some(Color("#ffffff")),
            eye_color: Some(Color("#ee7812")),
            passport_id: Some(ID("00023437")),
            country_id: None,
        }
        .build()
        .is_ok());
    }
}
