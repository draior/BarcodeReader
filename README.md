Build issue with XE6 - when the app is closed there is exception - invalid pointer.
To build project
  - delete all System.Classes.dcu
  - open System.Classes.pas found line where components are free -> FreeAndNil(FSortedComponents) and replace with FSortedComponents := nil;
