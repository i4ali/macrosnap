# Screen 2: Quick Log (Modal Sheet)

This screen slides up from the bottom when the user taps the "+" button. Speed is the #1 priority.

## "The Numeric Keypad"

This design uses a dedicated keypad, removing the need for the system keyboard.

```
/--------------------------------------\
|  Log Macros                 [Done]   |
| (Sheet Drag Handle)                  |
|                                      |
|  (P) Protein   [ 40       ] g        |
|  (C) Carbs     [ 30       ] g        |
|  (F) Fat       [ 10       ] g        |
|                                      |
|  [ 1 ]   [ 2 ]   [ 3 ]               |
|  [ 4 ]   [ 5 ]   [ 6 ]               |
|  [ 7 ]   [ 8 ]   [ 9 ]               |
|  [ . ]   [ 0 ]   [<--] (Backspace)   |
|                                      |
|  Notes (Optional) [🔒 PRO]           |
|  [__________________]                |
|                                      |
|  (Save as Preset) [🔒 PRO]           |
|                                      |
\--------------------------------------/
```

## Design Rationale

- **Fastest Entry**: No keyboard load time. Tapping a field focuses it, and the user just types. "Done" logs the entry.
- **Focused**: The UI is only about number entry.
- **Pro Upsell**: Clearly shows the value of "Notes" and "Presets" for Pro users.
