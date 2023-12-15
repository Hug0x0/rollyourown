/* Autogenerated file. Do not edit manually. */

import { defineComponent, Type as RecsType, World } from "@latticexyz/recs";

export function defineContractComponents(world: World) {
  return {
    Drug: (() => {
      const name = "Drug";
      return defineComponent(
        world,
        {
          quantity: RecsType.Number,
        },
        {
          metadata: {
            name: name,
            types: ["usize"],
          },
        },
      );
    })(),
    Encounter: (() => {
      const name = "Encounter";
      return defineComponent(
        world,
        {
          level: RecsType.Number,
          health: RecsType.Number,
          payout: RecsType.BigInt,
          demand_pct: RecsType.Number,
        },
        {
          metadata: {
            name: name,
            types: ["u8", "u8", "u128", "u8"],
          },
        },
      );
    })(),
    Game: (() => {
      const name = "Game";
      return defineComponent(
        world,
        {
          game_mode: RecsType.Number,
          start_time: RecsType.Number,
          max_players: RecsType.Number,
          num_players: RecsType.Number,
          max_turns: RecsType.Number,
          creator: RecsType.String,
        },
        {
          metadata: {
            name: name,
            types: ["GameMode", "u64", "usize", "usize", "usize", "ContractAddress"],
          },
        },
      );
    })(),
    Item: (() => {
      const name = "Item";
      return defineComponent(
        world,
        {
          level: RecsType.Number,
          name: RecsType.BigInt,
          value: RecsType.Number,
        },
        {
          metadata: {
            name: name,
            types: ["u8", "felt252", "usize"],
          },
        },
      );
    })(),
    Leaderboard: (() => {
      const name = "Leaderboard";
      return defineComponent(
        world,
        {
          high_score: RecsType.BigInt,
          next_version_timestamp: RecsType.Number,
        },
        {
          metadata: {
            name: name,
            types: ["u128", "u64"],
          },
        },
      );
    })(),
    Market: (() => {
      const name = "Market";
      return defineComponent(
        world,
        {
          cash: RecsType.BigInt,
          quantity: RecsType.Number,
        },
        {
          metadata: {
            name: name,
            types: ["u128", "usize"],
          },
        },
      );
    })(),
    Player: (() => {
      const name = "Player";
      return defineComponent(
        world,
        {
          mainnet_address: RecsType.String,
          name: RecsType.BigInt,
          avatar_id: RecsType.Number,
          status: RecsType.Number,
          hood_id: RecsType.Number,
          location_id: RecsType.Number,
          next_location_id: RecsType.Number,
          turn: RecsType.Number,
          max_turns: RecsType.Number,
          max_items: RecsType.Number,
          cash: RecsType.BigInt,
          health: RecsType.Number,
          drug_count: RecsType.Number,
          attack: RecsType.Number,
          defense: RecsType.Number,
          transport: RecsType.Number,
          speed: RecsType.Number,
          wanted: RecsType.Number,
          leaderboard_version: RecsType.Number,
          game_over: RecsType.Boolean,
        },
        {
          metadata: {
            name: name,
            types: [
              "ContractAddress",
              "felt252",
              "u8",
              "PlayerStatus",
              "LocationEnum",
              "LocationEnum",
              "LocationEnum",
              "usize",
              "usize",
              "u8",
              "u128",
              "u8",
              "usize",
              "usize",
              "usize",
              "usize",
              "usize",
              "u8",
              "u32",
              "bool",
            ],
          },
        },
      );
    })(),
    RyoMeta: (() => {
      const name = "RyoMeta";
      return defineComponent(
        world,
        {
          initialized: RecsType.Boolean,
          leaderboard_version: RecsType.Number,
        },
        {
          metadata: {
            name: name,
            types: ["bool", "u32"],
          },
        },
      );
    })(),
  };
}
