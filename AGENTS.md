# DreamValley — Agent Notes

## Build / Compile

This project compiles with OpenDream (not BYOND DreamMaker).

```powershell
& "C:\Users\lugin\Desktop\general\DreamValley\external\OpenDream\bin\DMCompiler\DMCompiler.exe" `
    --version=516.1666 --define=OPENDREAM `
    '--define=RUST_G="rust_g64.dll"' `
    --suppress-unimplemented --suppress-unsupported `
    roguetown.dme
```

A clean compile prints `Compilation succeeded` with 0 `Error OD` lines.
The `roguetown.json` output is the compiled game file.

## Sexcon / Chastity Port

The sexcon system was ported from Ratwood-2.0. Ratwood-specific paths that
don't exist in this codebase are stubbed in
`code/datums/sexcon/sexcon_port_stubs.dm` so the ported code compiles without
editing every call site. Key stub categories:

- **Patron aliases**: Xylix→Viator, Baotha→Hausvette, Eora→Miluse
- **Status effects**: stinky_contact, emberwine, cum_consumed, surrender/collar
- **Stress events**: cumok, cummax, unseemly_made_love, thrill, chastity_*
- **Components**: collar_master (minimal), intimate_reaction (full, in modular/)
- **Vars/procs**: has_gnoll_scent_this_round, bellsound, check_handholding,
  eora_register_consensual_pair, start_sex_session, log_chastity_command

The full chastity device system (core, equip, variants, cursed, keys, sprite
accessory, bodypart feature) lives under
`modular/code/game/objects/items/lewd/chastity/` and
`code/game/objects/items/rogueitems/keys_chastity.dm`.

Chastity-related defines are in `code/__DEFINES/sexcon_defines.dm`
(TRAIT_CHASTITY__, CHASTITY__ constants, BODYPART_FEATURE_CHASTITY,
COMSIG_CARBON_LOSE_CHASTITY).
