use itertools::Itertools;

fn main() -> anyhow::Result<()> {
	// p1
    let (a, b) = include_str!("input.txt")
    		.split_terminator('\n')
    		.map(str::parse::<i64>)
    		.collect::<Result<Vec<_>, _>>()?
    		.into_iter()
    		.tuple_combinations()
			.find(|(a, b)| a + b == 2020)
			.expect("no pair had a sum for 2020");
    dbg!(a + b);
    dbg!(a * b);

    // p2
    let (a, b, c) = include_str!("input.txt")
    		.split_terminator('\n')
    		.map(str::parse::<i64>)
    		.collect::<Result<Vec<_>, _>>()?
    		.into_iter()
    		.tuple_combinations()
			.find(|(a, b, c)| a + b + c == 2020)
			.expect("no tuple of 3 length had a sum for 2020");
	dbg!(a + b + c);
	dbg!(a * b * c);

	Ok(())
}
