//! Cleartext readable header containing not encrypted metadata
//! and the key slots.

use std::io::{Read, Write};

use anyhow::{Context, Error, Result};
use nom::{
    bytes::streaming::tag,
    combinator::all_consuming,
    error::context,
    multi::{length_count, length_data},
    number::complete::{le_u16, le_u32, le_u8},
    sequence::{pair, preceded},
};

pub const FILE_MAGIC_NUMBER: [u8; 8] = *b"ENCAPFS\0";

pub struct RootBlock {
    pub upper_header: UpperHeader,
    /// Encrypted data of the root block
    ///
    /// This could include all the data for small files or an encrypted directory of chunk.
    pub root_data: Vec<u8>,
}

impl RootBlock {
    pub fn write(&self, mut writer: impl Write) -> Result<()> {
        let encoded_upper_header = self.upper_header.encode()?;

        writer.write_all(
            &FileHeader {
                upper_header_size: encoded_upper_header
                    .len()
                    .try_into()
                    .context("Upper header is to large")?,
                root_data_size: self
                    .root_data
                    .len()
                    .try_into()
                    .context("Root data block is to large")?,
            }
            .encode(),
        )?;
        writer.write_all(&encoded_upper_header)?;
        writer.write_all(&self.root_data)?;

        Ok(())
    }

    pub fn read(&self, mut reader: impl Read) -> Result<Self> {
        let mut encoded_file_header = vec![0u8; FileHeader::ENCODED_SIZE];
        reader.read_exact(&mut encoded_file_header)?;
        let file_header = FileHeader::decode(&encoded_file_header)?;

        let mut encoded_upper_header = vec![
            0u8;
            file_header.upper_header_size.try_into().context(
                "pointer size should have at least 32bit"
            )?
        ];
        let upper_header = UpperHeader::decode(&encoded_upper_header)?;

        let root_data = vec![
            0u8;
            file_header
                .root_data_size
                .try_into()
                .context("pointer size should have at least 32bit")?
        ];

        Ok(RootBlock {
            upper_header,
            root_data,
        })
    }
}

fn parse_complete<'buf, O>(
    data: &'buf [u8],
    f: impl FnMut(&'buf [u8]) -> nom::IResult<&'buf [u8], O, nom::error::Error<&'buf [u8]>>,
) -> Result<O> {
    let (_rest, o) = all_consuming(f)(data)
        .map_err(|err: nom::Err<nom::error::Error<_>>| anyhow::Error::msg(err.to_string()))?;
    Ok(o)
}

#[derive(Debug, Clone, PartialEq, Eq)]
struct FileHeader {
    pub upper_header_size: u32,
    pub root_data_size: u32,
}

impl FileHeader {
    pub const ENCODED_SIZE: usize = FILE_MAGIC_NUMBER.len() + 4 + 4;

    pub fn encode(self) -> Vec<u8> {
        let mut buffer = Vec::with_capacity(Self::ENCODED_SIZE);

        buffer.extend_from_slice(&FILE_MAGIC_NUMBER);
        buffer.extend_from_slice(&self.upper_header_size.to_le_bytes());
        buffer.extend_from_slice(&self.root_data_size.to_le_bytes());

        buffer
    }

    pub fn decode(data: &[u8]) -> Result<Self> {
        let (upper_header_size, root_data_size) = parse_complete(
            data,
            preceded(
                context("Magic number is wrong", tag(FILE_MAGIC_NUMBER)),
                pair(le_u32, le_u32),
            ),
        )?;

        Ok(Self {
            upper_header_size,
            root_data_size,
        })
    }
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct UpperHeader {
    pub key_slots: Vec<KeySlot>,
}

impl UpperHeader {
    /// Encode the file header in binary
    ///
    /// The returned data will include the padding needed to satisfy
    /// [`UpperHeader::initial_data_offset`].
    ///
    /// If that
    ///
    /// # Errors
    ///
    /// Fails if more than 255 key slots are given or a key slot is invalid.
    #[allow(unused)]
    pub fn encode(&self) -> Result<Vec<u8>> {
        let mut buffer = Vec::new();
        let key_slot_count =
            u8::try_from(self.key_slots.len()).context("The maximum count of key slots is 255")?;

        // padding / reserved data
        buffer.extend_from_slice(&[0u8; 7]);
        buffer.extend_from_slice(&key_slot_count.to_le_bytes());

        for key_slot in &self.key_slots {
            key_slot.encode(&mut buffer)?;
        }

        Ok(buffer)
    }

    /// Decode the binary representation of the header
    ///
    /// # Errors
    ///
    /// Fails in case of a parsing error or if the data is not complete.
    #[allow(unused)]
    pub fn decode(data: &[u8]) -> Result<Self> {
        let (_rest, raw_key_slots) = preceded::<_, _, _, (), _, _>(
            tag([0u8; 7]),
            length_count(le_u8, pair(le_u16, length_data(le_u16))),
        )(data)
        .map_err(|_err| Error::msg("Could not parse root header"))?;

        let key_slots: Vec<_> = raw_key_slots
            .into_iter()
            .map(|(slot_type, raw_slot)| KeySlot::decode(slot_type, raw_slot))
            .collect();

        Ok(Self { key_slots })
    }
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum KeySlot {
    /// Passwords for humans
    Argon2id(Argon2idKeySlot),
    Unknown(RawKeySlot),
}

impl KeySlot {
    /// Encode as binary
    ///
    /// # Errors
    ///
    /// In case a unknown slot type is encoded and it's size does not fit in 16 bit
    pub fn encode(&self, buffer: &mut Vec<u8>) -> Result<()> {
        let (tag, slot_size) = match self {
            Self::Argon2id(slot) => (1u16, slot.salt.len()),
            Self::Unknown(raw) => (raw.key_type_id, raw.data.len()),
        };

        let length = u16::try_from(slot_size).context("Slot size should fit in 16 bits")?;

        buffer.extend_from_slice(&tag.to_le_bytes());
        buffer.extend_from_slice(&length.to_le_bytes());

        match self {
            Self::Argon2id(slot) => buffer.extend_from_slice(&slot.salt),
            Self::Unknown(slot) => buffer.extend_from_slice(&slot.data),
        }

        Ok(())
    }

    fn decode(slot_type_raw: u16, data: &[u8]) -> Self {
        match slot_type_raw {
            1 => Self::Argon2id(Argon2idKeySlot { salt: data.into() }),
            _ => Self::Unknown(RawKeySlot {
                key_type_id: slot_type_raw,
                data: data.into(),
            }),
        }
    }
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Argon2idKeySlot {
    pub salt: Vec<u8>,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct RawKeySlot {
    pub key_type_id: u16,
    pub data: Vec<u8>,
}

#[cfg(test)]
mod tests {
    use super::*;
    use pretty_assertions::assert_eq;

    const DUMMY_SALT: [u8; 16] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15];

    #[test]
    pub fn encode_file_header() {
        let header = FileHeader {
            upper_header_size: 23,
            root_data_size: 42,
        };

        let want = vec![
            b'E', b'N', b'C', b'A', b'P', b'F', b'S', 0, // magic number
            23, 0, 0, 0, // root data size
            42, 0, 0, 0, // upper header size
        ];

        let got = header.encode();
        assert_eq!(want, got);
    }

    #[test]
    pub fn decode_file_header() {
        let input = vec![
            b'E', b'N', b'C', b'A', b'P', b'F', b'S', 0, // magic number
            23, 0, 0, 0, // root data size
            42, 0, 0, 0, // upper header size
        ];

        let want = FileHeader {
            upper_header_size: 23,
            root_data_size: 42,
        };

        let got = FileHeader::decode(&input).expect("Correct data decodes");
        assert_eq!(want, got);
    }

    #[test]
    pub fn encode_argon_key_slot() {
        let slot = KeySlot::Argon2id(Argon2idKeySlot {
            salt: DUMMY_SALT.to_vec(),
        });

        let want = vec![
            1, 0, // type
            16, 0, // length
            0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,
        ];
        let mut got = vec![];

        slot.encode(&mut got).expect("Test data should encode");
        assert_eq!(want, got);
    }

    #[test]
    pub fn encode_unknown_key_slot() {
        let slot = KeySlot::Unknown(RawKeySlot {
            key_type_id: 23,
            data: vec![23, 42],
        });

        let want = vec![
            23, 0, //type
            2, 0, // length
            23, 42,
        ];
        let mut got = vec![];

        slot.encode(&mut got).expect("Test data should encode");
        assert_eq!(want, got);
    }

    #[test]
    pub fn encoding_header_roundtrip() {
        let header = UpperHeader {
            key_slots: vec![
                KeySlot::Argon2id(Argon2idKeySlot {
                    salt: DUMMY_SALT.to_vec(),
                }),
                KeySlot::Unknown(RawKeySlot {
                    key_type_id: 23,
                    data: vec![23, 42],
                }),
            ],
        };

        let encoded = header.encode().expect("Correct data encodes");
        let decoded = UpperHeader::decode(&encoded).expect("Correct data decodes");

        assert_eq!(header, decoded, "Original and decoded header are same");
    }
}
