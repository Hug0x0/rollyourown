use rollyourown::constants::SCALING_FACTOR;
use rollyourown::models::game::GameMode;
use rollyourown::models::drug::DrugEnum;
use rollyourown::models::item::ItemEnum;
use rollyourown::models::player::Player;


#[derive(Copy, Drop, Serde)]
struct GameSettings {
    max_players: usize,
    max_turns: usize,
}

#[derive(Copy, Drop, Serde)]
struct PlayerSettings {
    health: u8,
    cash: u128,
    wanted: u8,
    attack: usize,
    defense: usize,
    transport: usize,
    speed: usize,
}

// TODO: update % to %0
#[derive(Copy, Drop, Serde)]
struct RiskSettings {
    travel: u8,
    capture: u8,
    encounter_bias_gangs: u128,
    cops_drug_threshold: usize,
    gangs_cash_threshold: u128,
    wanted_decrease_by_turn: u8,
    wanted_decrease_zero_drug: u8,
    wanted_increase_by_drug: u8,
}

#[derive(Copy, Drop, Serde)]
struct MarketSettings {
    price_var_chance: usize,
    price_var_min: u8,
    price_var_max: u8,
    market_event_chance: usize,
    market_event_min: usize,
    market_event_max: usize,
    liq_scaling_initial_rate: usize,
    liq_scaling_fading_rate: usize,
}

#[derive(Copy, Drop, Serde)]
struct DecideSettings {
    gangs_payment_cash_pct: usize,
    cops_payment_drug_pct: usize,
    health_impact: u8,
    wanted_impact_run: u8,
    wanted_impact_fight: u8,
}

#[derive(Copy, Drop, Serde)]
struct PriceSettings {
    min_price: u128,
    max_price: u128,
    min_qty: u128,
    max_qty: u128,
}

#[derive(Copy, Drop, Serde)]
struct ItemSettings {
    name: felt252,
    cost: u128,
    value: usize
}

#[derive(Copy, Drop, Serde)]
struct ShopSettings {
    max_item_allowed: u8,
    max_item_level: u8,
    opening_freq: u32
}


#[derive(Copy, Drop, Serde)]
struct EncounterSettings {
    level: u8,
    health: u8,
    dmg: u8,
    payout: u128,
}

//
//
//

trait SettingsTrait<T> {
    fn get(game_mode: GameMode) -> T;
}

trait DrugSettingsTrait<T> {
    fn get(game_mode: GameMode, drug_id: DrugEnum) -> T;
}

trait PlayerSettingsTrait<T> {
    fn get(game_mode: GameMode, player: @Player) -> T;
}

trait ItemSettingsTrait<T> {
    fn get(game_mode: GameMode, item_id: ItemEnum, level: u8) -> T;
}

trait EncounterSettingsTrait<T> {
    fn get(player: @Player, level: u8) -> T;
}

//
//
//

impl GameSettingsImpl of SettingsTrait<GameSettings> {
    fn get(game_mode: GameMode) -> GameSettings {
        match game_mode {
            GameMode::Limited => {
                GameSettings { max_players: 1, max_turns: 10 }
            },
            GameMode::Unlimited => {
                GameSettings { max_players: 1, max_turns: 0 }
            },
        }
    }
}

impl PlayerSettingsImpl of SettingsTrait<PlayerSettings> {
    fn get(game_mode: GameMode) -> PlayerSettings {
        match game_mode {
            GameMode::Limited => {
                PlayerSettings {
                    health: 100_u8,
                    cash: 2000_u128 * SCALING_FACTOR,
                    wanted: 100, // TODO: revert to 39,
                    attack: 0,
                    defense: 0,
                    transport: 100,
                    speed: 0
                }
            },
            GameMode::Unlimited => {
                PlayerSettings {
                    health: 100_u8,
                    cash: 1500_u128 * SCALING_FACTOR,
                    wanted: 100, // TODO: revert to 39,
                    attack: 0,
                    defense: 0,
                    transport: 100,
                    speed: 0
                }
            },
        }
    }
}


impl RiskSettingsImpl of PlayerSettingsTrait<RiskSettings> {
    fn get(game_mode: GameMode, player: @Player) -> RiskSettings {
        match game_mode {
            GameMode::Limited => {
                let travel: u8 = (45
                    + (*player).wanted / 2); // 45% chance of travel encounter + 0.5 wanted (max 50)
                let capture: u8 = (60
                    + (*player).wanted / 5); // 60% chance of capture + 0.2 wanted (max 20)

                RiskSettings {
                    travel,
                    capture,
                    encounter_bias_gangs: 50, // 50% chance of gangs encounter vs cops
                    cops_drug_threshold: 5, // cops encounter threshold
                    gangs_cash_threshold: 1000_0000, // gangs encounter threshold
                    wanted_decrease_by_turn: 3,
                    wanted_decrease_zero_drug: 20,
                    wanted_increase_by_drug: ((*player).drug_count / 7).try_into().unwrap()
                }
            },
            GameMode::Unlimited => {
                let travel = (45
                    + (*player).wanted / 2); // 45% chance of travel encounter + 0.5 wanted (max 50)
                let capture = (50
                    + (*player).wanted / 5); // 50% chance of capture + 0.2 wanted (max 20)

                RiskSettings {
                    travel,
                    capture,
                    encounter_bias_gangs: 50, // 50% chance of gangs encounter vs cops
                    cops_drug_threshold: 10, // cops encounter threshold
                    gangs_cash_threshold: 1000_0000, // gangs encounter threshold
                    wanted_decrease_by_turn: 1,
                    wanted_decrease_zero_drug: 10,
                    wanted_increase_by_drug: ((*player).drug_count / 7).try_into().unwrap()
                }
            },
        }
    }
}


impl DecideSettingsImpl of PlayerSettingsTrait<DecideSettings> {
    fn get(game_mode: GameMode, player: @Player) -> DecideSettings {
        match game_mode {
            GameMode::Limited => {
                DecideSettings {
                    gangs_payment_cash_pct: 20, //% of cash
                    cops_payment_drug_pct: 20, //% of drug
                    health_impact: (10 + ((*player).turn / 3 * 2))
                        .try_into()
                        .unwrap(), // 10 + (2 each 3 turn)
                    wanted_impact_run: 4,
                    wanted_impact_fight: 10,
                }
            },
            GameMode::Unlimited => {
                DecideSettings {
                    gangs_payment_cash_pct: 20, //% of cash
                    cops_payment_drug_pct: 20, //% of drug
                    health_impact: (8 + ((*player).turn / 5))
                        .try_into()
                        .unwrap(), // 10 + (1 each 5 turn)
                    wanted_impact_run: 4,
                    wanted_impact_fight: 10,
                }
            },
        }
    }
}

impl MarketSettingsImpl of SettingsTrait<MarketSettings> {
    fn get(game_mode: GameMode) -> MarketSettings {
        match game_mode {
            GameMode::Limited => {
                MarketSettings {
                    price_var_chance: 250, // on 1000 : 50% chance = 25% up / 25% down
                    price_var_min: 1, // 1%  
                    price_var_max: 5, // 5%  
                    market_event_chance: 7, // on 1000 : 1.4% = 0.7% up / 0.7% down
                    market_event_min: 50, //   up 50%   | down 25%
                    market_event_max: 100, //   up 100%  | down 50%
                    liq_scaling_initial_rate: 200, // 0.02
                    liq_scaling_fading_rate: 420,
                }
            },
            GameMode::Unlimited => {
                MarketSettings {
                    price_var_chance: 250, // on 1000 : 50% chance = 25% up / 25% down
                    price_var_min: 1, // 1%  
                    price_var_max: 5, // 5%  
                    market_event_chance: 7, // on 1000 : 1.4% = 0.7% up / 0.7% down   TODO: rollback
                    market_event_min: 50, //   up 50%   | down 25%
                    market_event_max: 100, //   up 100%  | down 50%
                    liq_scaling_initial_rate: 140, // 0.014
                    liq_scaling_fading_rate: 350,
                }
            },
        }
    }
}

//
//
//

impl ShopSettingsImpl of SettingsTrait<ShopSettings> {
    fn get(game_mode: GameMode) -> ShopSettings {
        match game_mode {
            GameMode::Limited => {
                ShopSettings { max_item_allowed: 2, max_item_level: 1, opening_freq: 2 }
            },
            GameMode::Unlimited => {
                ShopSettings { max_item_allowed: 3, max_item_level: 3, opening_freq: 2 }
            },
        }
    }
}

impl ItemSettingsImpl of ItemSettingsTrait<ItemSettings> {
    fn get(game_mode: GameMode, item_id: ItemEnum, level: u8) -> ItemSettings {
        match game_mode {
            GameMode::Limited => {
                // level is ignored in Limited mode
                match item_id {
                    ItemEnum::Attack => ItemSettings {
                        name: 'Knife', cost: 500 * SCALING_FACTOR, value: 20
                    },
                    ItemEnum::Defense => ItemSettings {
                        name: 'Knee pads', cost: 350 * SCALING_FACTOR, value: 35
                    },
                    ItemEnum::Transport => ItemSettings {
                        name: 'Fanny pack', cost: 600 * SCALING_FACTOR, value: 20
                    },
                    ItemEnum::Speed => ItemSettings {
                        name: 'Shoes', cost: 350 * SCALING_FACTOR, value: 15
                    },
                }
            },
            GameMode::Unlimited => {
                match item_id {
                    ItemEnum::Attack => {
                        if level == 1 {
                            ItemSettings { name: 'Knife', cost: 250 * SCALING_FACTOR, value: 10 }
                        } else if level == 2 {
                            ItemSettings { name: 'Glock', cost: 4200 * SCALING_FACTOR, value: 25 }
                        } else {
                            ItemSettings { name: 'Uzi', cost: 38000 * SCALING_FACTOR, value: 50 }
                        }
                    },
                    ItemEnum::Defense => {
                        if level == 1 {
                            ItemSettings {
                                name: 'Knee pads', cost: 350 * SCALING_FACTOR, value: 25
                            }
                        } else if level == 2 {
                            ItemSettings {
                                name: 'Leather Jacket', cost: 3700 * SCALING_FACTOR, value: 40
                            }
                        } else {
                            ItemSettings { name: 'Kevlar', cost: 28000 * SCALING_FACTOR, value: 60 }
                        }
                    },
                    ItemEnum::Transport => {
                        if level == 1 {
                            ItemSettings {
                                name: 'Fanny pack', cost: 450 * SCALING_FACTOR, value: 20
                            }
                        } else if level == 2 {
                            ItemSettings {
                                name: 'Backpack', cost: 6900 * SCALING_FACTOR, value: 50
                            }
                        } else {
                            ItemSettings {
                                name: 'Duffle Bag', cost: 42000 * SCALING_FACTOR, value: 100
                            }
                        }
                    },
                    ItemEnum::Speed => {
                        if level == 1 {
                            ItemSettings { name: 'Shoes', cost: 250 * SCALING_FACTOR, value: 10 }
                        } else if level == 2 {
                            ItemSettings {
                                name: 'Skateboard', cost: 2400 * SCALING_FACTOR, value: 25
                            }
                        } else {
                            ItemSettings {
                                name: 'Bicycle', cost: 32000 * SCALING_FACTOR, value: 40
                            }
                        }
                    },
                }
            },
        }
    }
}

//
//
//

impl EncounterSettingsImpl of EncounterSettingsTrait<EncounterSettings> {
    fn get(player: @Player, level: u8) -> EncounterSettings {
        // game should not exceed 100 turns
        let turn: u8 = (*player.turn).try_into().unwrap();
        let mut health = level * 10 + turn;
        let mut health = if health > 100 {
            100
        } else {
            health
        };
        let dmg = health / 4;
        let payout: u128 = SCALING_FACTOR * level.into() * (10000 + (1000 * turn.into()));

        EncounterSettings { level, health, dmg, payout }
    }
}


//
//
//

impl PriceSettingsImpl of DrugSettingsTrait<PriceSettings> {
    fn get(game_mode: GameMode, drug_id: DrugEnum) -> PriceSettings {
        match game_mode {
            GameMode::Limited => {
                pricing(drug_id)
            },
            GameMode::Unlimited => {
                pricing(drug_id)
            },
        }
    }
}

fn pricing(drug_id: DrugEnum) -> PriceSettings {
    match drug_id {
        DrugEnum::Ludes => {
            PriceSettings {
                min_price: 15 * SCALING_FACTOR,
                max_price: 105 * SCALING_FACTOR,
                min_qty: 1500,
                max_qty: 3000,
            }
        },
        DrugEnum::Speed => {
            PriceSettings {
                min_price: 90 * SCALING_FACTOR,
                max_price: 540 * SCALING_FACTOR,
                min_qty: 1200,
                max_qty: 2400,
            }
        },
        DrugEnum::Weed => {
            PriceSettings {
                min_price: 450 * SCALING_FACTOR,
                max_price: 2250 * SCALING_FACTOR,
                min_qty: 1000,
                max_qty: 2000,
            }
        },
        DrugEnum::Acid => {
            PriceSettings {
                min_price: 1800 * SCALING_FACTOR,
                max_price: 7200 * SCALING_FACTOR,
                min_qty: 800,
                max_qty: 1600,
            }
        },
        DrugEnum::Heroin => {
            PriceSettings {
                min_price: 5400 * SCALING_FACTOR,
                max_price: 16200 * SCALING_FACTOR,
                min_qty: 600,
                max_qty: 1200,
            }
        },
        DrugEnum::Cocaine => {
            PriceSettings {
                min_price: 10800 * SCALING_FACTOR,
                max_price: 21600 * SCALING_FACTOR,
                min_qty: 500,
                max_qty: 1000,
            }
        },
    }
}
