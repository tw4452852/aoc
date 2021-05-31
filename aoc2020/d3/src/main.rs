use std::fmt;
use std::ops::AddAssign;

fn main() {
    let map = Map::parse(include_bytes!("input.txt"));
    // p1
    let itinerary = (0..map.size.y).into_iter().map(|y| Vec2::from((y * 3, y)));
    let num_trees = itinerary.filter(|&pos| map.get(pos) == Tile::Tree).count();
    dbg!(num_trees);

    // p2
    let deltas: &[Vec2] = &[
        (1, 1).into(),
        (3, 1).into(),
        (5, 1).into(),
        (7, 1).into(),
        (1, 2).into(),
    ];

    let answer = deltas
        .iter()
        .copied()
        .map(|delta| generate_itinerary(&map, delta))
        .map(|itin| {
            itin.into_iter()
                .filter(|&pos| map.get(pos) == Tile::Tree)
                .count()
        })
        .product::<usize>();
    dbg!(answer);
}

fn generate_itinerary(map: &Map, delta: Vec2) -> Vec<Vec2> {
    let mut pos = Vec2::from((0, 0));
    let mut res: Vec<_> = Default::default();
    while map.normalize_pos(pos).is_some() {
        res.push(pos);
        pos += delta;
    }
    res
}

#[derive(Debug, Clone, Copy, PartialEq)]
struct Vec2 {
    x: i64,
    y: i64,
}

impl From<(i64, i64)> for Vec2 {
    fn from((x, y): (i64, i64)) -> Self {
        Self { x, y }
    }
}

impl AddAssign for Vec2 {
    fn add_assign(&mut self, rhs: Self) {
        self.x += rhs.x;
        self.y += rhs.y;
    }
}

#[derive(Clone, Copy, PartialEq)]
enum Tile {
    Open,
    Tree,
}

impl Default for Tile {
    fn default() -> Self {
        Self::Open
    }
}

impl fmt::Debug for Tile {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let c = match self {
            Tile::Open => '.',
            Tile::Tree => '#',
        };
        write!(f, "{}", c)
    }
}

struct Map {
    size: Vec2,
    tiles: Vec<Tile>,
}

impl Map {
    fn parse(input: &[u8]) -> Self {
        let mut columns = 0;
        let mut col = 0;
        let mut rows = 1;
        for &c in input {
            if c == b'\n' {
                rows += 1;
                if col > columns {
                    columns = col
                }
                col = 0;
            } else {
                col += 1;
            }
        }
        if col == 0 {
            rows -= 1;
        }
        let mut map = Self::new((columns, rows).into());
        for row in 0..rows {
            for col in 0..columns {
                let tile = match input[(row * (1 + columns) + col) as usize] {
                    b'.' => Tile::Open,
                    b'#' => Tile::Tree,
                    c => panic!("not expected character {} at {},{}", c, row, col),
                };
                map.set((col, row).into(), tile);
            }
        }
        map
    }

    fn new(size: Vec2) -> Self {
        let num_tiles = size.x * size.y;
        Self {
            size,
            tiles: (0..num_tiles)
                .into_iter()
                .map(|_| Default::default())
                .collect(),
        }
    }

    fn set(&mut self, pos: Vec2, tile: Tile) {
        if let Some(i) = self.index(pos) {
            self.tiles[i] = tile;
        }
    }

    fn get(&self, pos: Vec2) -> Tile {
        self.index(pos).map(|i| self.tiles[i]).unwrap_or_default()
    }

    fn normalize_pos(&self, pos: Vec2) -> Option<Vec2> {
        if pos.y < 0 || pos.y >= self.size.y {
            None
        } else {
            let x = if pos.x < 0 {
                self.size.x + (pos.x % self.size.x)
            } else {
                pos.x % self.size.x
            };
            Some((x, pos.y).into())
        }
    }

    fn index(&self, pos: Vec2) -> Option<usize> {
        self.normalize_pos(pos)
            .map(|pos| (pos.x + pos.y * self.size.x) as _)
    }
}

impl fmt::Debug for Map {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        for row in 0..self.size.y {
            for col in 0..self.size.x {
                write!(f, "{:?}", self.get((col, row).into()))?;
            }
            writeln!(f)?
        }
        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_parse() {
        let input = b".#.\n...\n###\n";
        let m = Map::parse(input);
        assert_eq!(format!("{:?}", m), String::from_utf8_lossy(input));
    }

    #[test]
    fn test_tuple() {
        let v: Vec2 = (1, 2).into();
        assert_eq!(v.x, 1);
        assert_eq!(v.y, 2);
    }

    #[test]
    fn test_normalize_pos() {
        let m = Map::new((2, 2).into());
        assert_eq!(m.normalize_pos((0, 0).into()), Some((0, 0).into()));
        assert_eq!(m.normalize_pos((2, 0).into()), Some((0, 0).into()));
        assert_eq!(m.normalize_pos((-1, 0).into()), Some((1, 0).into()));
        assert_eq!(m.normalize_pos((0, -1).into()), None);
        assert_eq!(m.normalize_pos((0, 3).into()), None);
    }

    #[test]
    fn test_index() {
        let m = Map::new((2, 2).into());
        assert_eq!(m.index((0, 0).into()), Some(0));
        assert_eq!(m.index((0, 1).into()), Some(2));
        assert_eq!(m.index((5, 0).into()), Some(1));
        assert_eq!(m.index((0, 2).into()), None);
    }

    #[test]
    fn test_generate_itinerary() {
        assert_eq!(
            &generate_itinerary(&Map::new((5, 5).into()), (1, 1).into()),
            &[
                (0, 0).into(),
                (1, 1).into(),
                (2, 2).into(),
                (3, 3).into(),
                (4, 4).into(),
            ]
        )
    }
}
