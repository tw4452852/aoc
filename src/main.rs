use std::{collections::HashMap, error::Error, ops::Range, str::FromStr};
use std::{
    collections::HashSet,
    io::{stdin, Read},
};
#[macro_use]
extern crate lazy_static;
use regex::Regex;

type Result<T> = std::result::Result<T, Box<dyn Error>>;
macro_rules! err {
    ($($tt:tt)*) => { Err(Box::<dyn Error>::from(format!($($tt)*))) }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn iter_points() {
        assert_eq!(
            vec![(0, 0), (1, 0)],
            Claim {
                id: 0,
                x: 0,
                y: 0,
                w: 2,
                h: 1,
            }
            .iter_points()
            .collect::<Vec<(u32, u32)>>()
        );
    }

    #[test]
    fn parse_d4() {
        assert_eq!(
            Record {
                datetime: DateTime {
                    year: 1518,
                    month: 7,
                    day: 19,
                    hour: 0,
                    minute: 31,
                },
                kind: Kind::Sleep,
            },
            "[1518-07-19 00:31] falls asleep".parse::<Record>().unwrap()
        );
        assert_eq!(
            Record {
                datetime: DateTime {
                    year: 1518,
                    month: 7,
                    day: 19,
                    hour: 0,
                    minute: 31,
                },
                kind: Kind::Shift(1663),
            },
            "[1518-07-19 00:31] Guard #1663 begins shift"
                .parse::<Record>()
                .unwrap()
        );
        assert_eq!(
            Record {
                datetime: DateTime {
                    year: 1518,
                    month: 7,
                    day: 19,
                    hour: 0,
                    minute: 31,
                },
                kind: Kind::WakeUp,
            },
            "[1518-07-19 00:31] wakes up".parse::<Record>().unwrap()
        );
    }
}

fn main() -> Result<()> {
    let mut input = String::new();
    stdin().read_to_string(&mut input)?;

    if false {
        d1_p1(&input)?;
        d1_p2(&input)?;
        d2_p1(&input)?;
        d2_p2(&input)?;
        d3_p1_p2(&input)?;
    }
    d4_p1(&input)?;

    Ok(())
}

fn d4_p1(s: &str) -> Result<()> {
    let mut records = vec![];

    for line in s.lines() {
        let record: Record = line
            .parse()
            .or_else(|err| err!("line {}: parse err {}", line, err))?;
        records.push(record);
    }

    records.sort_by(|a, b| a.datetime.cmp(&b.datetime));

    let mut sleeps: HashMap<GuardID, Vec<Range<u32>>> = HashMap::new();
    let mut current_id: Option<GuardID> = None;
    let mut fell_sleep: Option<&DateTime> = None;
    for r in &records {
        match r.kind {
            Kind::Shift(id) => current_id = Some(id),
            Kind::Sleep => fell_sleep = Some(&r.datetime),
            Kind::WakeUp => {
                if current_id.is_some() && fell_sleep.is_some() {
                    let start = fell_sleep.unwrap().minute;
                    let end = r.datetime.minute;
                    sleeps
                        .entry(current_id.unwrap())
                        .or_default()
                        .push(start..end);
                }
            }
        }
    }

    fn sleepest_min(s: &Vec<Range<u32>>) -> (u32, u32) {
        let mut freq = [0u32; 60];
        s.iter().for_each(|x| {
            for i in x.start..x.end {
                freq[i as usize] += 1;
            }
        });

        let max = freq.iter().enumerate().max_by_key(|&(_, &x)| x).unwrap();

        (max.0 as u32, *max.1)
    }

    // p1
    {
        let sleepest_time = sleeps
            .iter()
            .max_by_key(|&(_id, times)| times.iter().fold(0, |s, x| s + x.end - x.start))
            .unwrap();

        let min = sleepest_min(sleepest_time.1).0;

        dbg!(min * sleepest_time.0);
    }

    // p2
    {
        let mut records: Vec<(GuardID, (u32, u32))> = Vec::new();

        sleeps.iter().for_each(|(id, times)| {
            records.push((*id, sleepest_min(times)));
        });

        let max = records.iter().max_by_key(|&&(_, (_, c))| c).unwrap();

        dbg!(max.0 * max.1.0);
    }

    Ok(())
}

#[derive(Debug, PartialEq, Eq, PartialOrd, Ord)]
struct DateTime {
    year: u32,
    month: u32,
    day: u32,
    hour: u32,
    minute: u32,
}

type GuardID = u32;
#[derive(Debug, PartialEq, Eq)]
enum Kind {
    WakeUp,
    Sleep,
    Shift(GuardID),
}

#[derive(Debug, PartialEq, Eq)]
struct Record {
    datetime: DateTime,
    kind: Kind,
}

impl FromStr for Record {
    type Err = Box<dyn Error>;

    fn from_str(s: &str) -> Result<Self> {
        lazy_static! {
            static ref RE: Regex = Regex::new(
                r"(?x)
            \[
                (?P<year>\d+)-(?P<month>\d+)-(?P<day>\d+)
                \s+
                (?P<hour>\d+):(?P<minute>\d+)
            \]
            \s+
            (?:Guard\ \#(?P<id>\d+)\ begins\ shift|(?P<sleep>.+))
        "
            )
            .unwrap();
        }

        let group = match RE.captures(s) {
            Some(group) => group,
            None => return Err(Box::<dyn Error>::from(format!("capture failed"))),
        };

        let datetime = DateTime {
            year: group["year"].parse()?,
            month: group["month"].parse()?,
            day: group["day"].parse()?,
            hour: group["hour"].parse()?,
            minute: group["minute"].parse()?,
        };
        let kind = if let Some(m) = group.name("id") {
            Kind::Shift(m.as_str().parse()?)
        } else if &group["sleep"] == "falls asleep" {
            Kind::Sleep
        } else {
            Kind::WakeUp
        };

        Ok(Record { datetime, kind })
    }
}

struct Claim {
    id: u32,
    x: u32,
    y: u32,
    h: u32,
    w: u32,
}

struct IterPoints<'c> {
    claim: &'c Claim,
    x: u32,
    y: u32,
}

impl<'c> Iterator for IterPoints<'c> {
    type Item = (u32, u32);

    fn next(&mut self) -> Option<Self::Item> {
        if self.y == self.claim.y + self.claim.h {
            return None;
        }

        let (x, y) = (self.x, self.y);

        self.x = if x + 1 == self.claim.x + self.claim.w {
            self.y += 1;
            self.claim.x
        } else {
            x + 1
        };

        Some((x, y))
    }
}

impl Claim {
    fn iter_points(&self) -> IterPoints {
        IterPoints {
            claim: self,
            x: self.x,
            y: self.y,
        }
    }
}

impl FromStr for Claim {
    type Err = Box<dyn Error>;

    fn from_str(s: &str) -> Result<Self> {
        lazy_static! {
            static ref RE: Regex = Regex::new(
                r"(?x)
            \#
            (?P<id>\d+)
            \s+@\s+
            (?P<x>\d+),(?P<y>\d+):
            \s+
            (?P<w>\d+)x(?P<h>\d+)
        "
            )
            .unwrap();
        }

        let cap = match RE.captures(s) {
            None => return Err(Box::<dyn Error>::from(format!("invalid input"))),
            Some(cap) => cap,
        };

        Ok(Claim {
            id: cap["id"].parse()?,
            x: cap["x"].parse()?,
            y: cap["y"].parse()?,
            w: cap["w"].parse()?,
            h: cap["h"].parse()?,
        })
    }
}

fn d3_p1_p2(input: &str) -> Result<()> {
    let mut claims = vec![];
    let mut grid: HashMap<(u32, u32), u32> = HashMap::new();

    for line in input.lines() {
        let claim: Claim = line
            .parse()
            .or_else(|_| Err(Box::<dyn Error>::from(format!("parse error"))))?;

        claims.push(claim);
    }

    for claim in &claims {
        for p in claim.iter_points() {
            *grid.entry(p).or_default() += 1;
        }
    }

    dbg!(grid.values().filter(|&&x| x > 1).count());

    for claim in &claims {
        if claim.iter_points().all(|x| grid[&x] == 1) {
            dbg!(claim.id);
        }
    }

    Ok(())
}

fn d2_p2(input: &str) -> Result<()> {
    let lines = input.lines().collect::<Vec<&str>>();

    fn find_common(a: &str, b: &str) -> Option<String> {
        if a.len() != b.len() {
            return None;
        }

        let mut find_one_wrong = false;
        for (a, b) in a.chars().zip(b.chars()) {
            if a != b {
                if find_one_wrong {
                    return None;
                }
                find_one_wrong = true;
            }
        }

        Some(
            a.chars()
                .zip(b.chars())
                .filter(|&(a, b)| a == b)
                .map(|(a, _)| a)
                .collect(),
        )
    }

    for i in 0..lines.len() {
        for j in i + 1..lines.len() {
            if let Some(common) = find_common(lines[i], lines[j]) {
                dbg!(common);
            }
        }
    }

    Ok(())
}

fn d2_p1(input: &str) -> Result<()> {
    let (mut twos, mut threes) = (0, 0);
    let mut freqs = [0u8; 256];

    for line in input.lines() {
        if !line.is_ascii() {
            println!("not accept non-ascii char");
            continue;
        }

        for f in freqs.iter_mut() {
            *f = 0;
        }

        for c in line.chars() {
            freqs[c as usize] = freqs[c as usize].saturating_add(1);
        }

        if freqs.iter().any(|&x| x == 2) {
            twos += 1;
        }
        if freqs.iter().any(|&x| x == 3) {
            threes += 1;
        }
    }
    dbg!(twos * threes);
    Ok(())
}

fn d1_p1(input: &str) -> Result<()> {
    let mut freq = 0;

    for line in input.lines() {
        freq += line.parse::<i32>()?;
    }
    dbg!(freq);

    Ok(())
}

fn d1_p2(input: &str) -> Result<()> {
    let mut seen = HashSet::new();
    seen.insert(0);
    let mut freq = 0;

    loop {
        for line in input.lines() {
            freq += line.parse::<i32>()?;
            if seen.contains(&freq) {
                dbg!(freq);
                return Ok(());
            }

            seen.insert(freq);
        }
    }
}
