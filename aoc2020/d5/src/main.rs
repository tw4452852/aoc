use bitvec::prelude::*;

fn main() {
    let input = include_str!("input.txt");
    // p1
    dbg!(input.lines().map(Seat::parse).max());

    // p2
    let mut ids: Vec<_> = input.lines().map(Seat::parse).collect();
    ids.sort();
    let mut last_id: Option<Seat> = None;
    for id in ids {
        if let Some(last_id) = last_id {
            let gap = id.0 - last_id.0;
            if gap > 1 {
                dbg!(last_id.0 + 1);
                return;
            }
        }
        last_id = Some(id);
    }
}

#[derive(Default, Debug, PartialEq, Eq, Ord, PartialOrd)]
struct Seat(u16);

impl Seat {
    fn parse(input: &str) -> Self {
        let bytes = input.as_bytes();
        let mut res: Seat = Default::default();

        let row = BitSlice::<Lsb0, _>::from_element_mut(&mut res.0);
        for (i, &b) in bytes.iter().rev().enumerate() {
            row.set(
                i,
                match b {
                    b'F' | b'L' => false,
                    b'B' | b'R' => true,
                    _ => panic!("unexpected letter: {}", b as char),
                },
            );
        }

        res
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_id() {
        macro_rules! validate {
            ($input: expr, $id: expr) => {
                let seat = Seat::parse($input);
                assert_eq!(seat.0, $id);
            };
        }

        validate!("BFFFBBFRRR", 567);
        validate!("FFFBBBFRRR", 119);
        validate!("BBFFBBFRLL", 820);
    }
}
