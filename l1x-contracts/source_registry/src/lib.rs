use borsh::{BorshDeserialize, BorshSerialize};
use l1x_sdk::types::Address;
use l1x_sdk::{contract, store::LookupMap, types::U64};
use serde::{Deserialize, Serialize};

const STORAGE_CONTRACT_KEY: &[u8] = b"REGISTRY";
const REGISTRY_SOURCES: &[u8] = b"REGKEY";

#[derive(
    Serialize,
    Deserialize,
    Clone,
    Debug,
    Eq,
    PartialEq,
    BorshSerialize,
    BorshDeserialize,
)]
pub struct EventSource {
    pub flow_contract_address: String,
    pub source_id: String,
    pub chain: String,
    pub source_type: String,
    pub smart_contract_address: String,
    pub event_type: String,
    pub event_filters: Vec<String>,
}

#[derive(
    Serialize,
    Deserialize,
    Clone,
    Debug,
    Eq,
    PartialEq,
    BorshSerialize,
    BorshDeserialize,
)]
pub enum Operation {
    Create,
    Remove,
}

#[derive(
    Serialize,
    Deserialize,
    Clone,
    Debug,
    Eq,
    PartialEq,
    BorshSerialize,
    BorshDeserialize,
)]
pub struct EventSourceOp {
    pub event_source: EventSource,
    pub op: Operation,
}

#[derive(BorshSerialize, BorshDeserialize)]
pub struct SourceRegistry {
    pub sources: LookupMap<U64, EventSourceOp>,
    pub index: U64,
}

#[contract]
impl SourceRegistry {
    pub fn new() {
        let mut contract = SourceRegistry {
            sources: LookupMap::new(REGISTRY_SOURCES.to_vec()),
            index: U64::from(0),
        };
        contract.save();
    }

    fn load() -> Self {
        match l1x_sdk::storage_read(STORAGE_CONTRACT_KEY) {
            Some(bytes) => Self::try_from_slice(&bytes).unwrap(),
            None => panic!("The contract isn't initialized"),
        }
    }

    fn save(&mut self) {
        let encoded_contract = borsh::BorshSerialize::try_to_vec(self).unwrap();
        l1x_sdk::storage_write(STORAGE_CONTRACT_KEY, &encoded_contract);
    }

    pub fn register_new_source(
        flow_contract_address: String,
        source_id: String,
        chain: String,
        source_type: String,
        smart_contract_address: String,
        event_type: String,
        event_filters: Vec<String>,
    ) -> Result<U64, String> {
        let mut contract = Self::load();
        let new_source: EventSource = EventSource {
            flow_contract_address,
            source_id,
            chain,
            source_type,
            smart_contract_address,
            event_type,
            event_filters,
        };
        let source_op = EventSourceOp {
            event_source: new_source.clone(),
            op: Operation::Create,
        };

        let index = {
            contract.index.0 = contract.index.0 + 1;
            contract.index
        };
        contract.sources.set(index, Some(source_op));
        contract.save();
        Ok(index)
    }

    pub fn unregister_source(index: U64) {
        let mut contract = Self::load();
        if let Some(source_op) = contract.sources.get(&index) {
            let mut source_op = source_op.clone();
            source_op.op = Operation::Remove;

            let index = {
                contract.index.0 = contract.index.0 + 1;
                contract.index
            };
            contract.sources.set(index, Some(source_op));
            contract.save();
        }
    }

    pub fn get_sources_from(from_index: U64) -> (u64, Vec<EventSourceOp>) {
        let contract = Self::load();
        let mut sources: Vec<EventSourceOp> = vec![];
        let mut from_index = from_index;
        let to_index = contract.index.0;
        for index in from_index.0..to_index {
            if let Some(source_op) = contract.sources.get(&U64::from(index)) {
                sources.push(source_op.clone());
                from_index.0 += 1;
            }
        }
        (from_index.into(), sources)
    }

    pub fn get_source(index: U64) -> Option<EventSourceOp> {
        let contract = Self::load();
        contract.sources.get(&index).cloned()
    }
}

// this is to verify that the caller is allowed to register source. need "get_contract_admins" to be implemented.
//
// let call = l1x_sdk::contract_interaction::ContractCall {
//     contract_address: l1x_sdk::types::Address::try_from(new_source.clone().flow_contract_address).map_err(|e| e.to_string())?,
//     method_name: "get_contract_admins".to_string(),
//     args: vec![],
//     read_only: true,
//     fee_limit: 0,
// };
// let res = l1x_sdk::call_contract(&call).ok_or("Failed to call contract")?;
// let authorized_addresses = serde_json::from_slice::<Vec<Address>>(&res).map_err(|e| e.to_string())?;
//
// let caller_address = l1x_sdk::caller_address();
// if !authorized_addresses.contains(&caller_address) {
//     return Err("Caller is not authorized to register new source".into());
// }

// contract.sources
// let mut current_sources: Vec<EventSource> =
//     if let Some(recent_sources) = l1x_sdk::storage_read(REGISTRY_SOURCES) {
//         serde_json::from_slice(&recent_sources).map_err(|e| e.to_string())?
//     } else {
//         vec![]
//     };
