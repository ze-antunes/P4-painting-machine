```
Microsoft Windows [Version 10.0.19044.1586]
(c) Microsoft Corporation. Todos os direitos reservados.

C:\Users\Antunes\Desktop\Universidade\2021-2022\2º Semestre\Projeto 4  - Multimédia Interativo\Repo P4-painting-machine\Meta 2\Harmonograph> npm start
npm ERR! missing script: start

npm ERR! A complete log of this run can be found in:
npm ERR!     C:\Users\Antunes\AppData\Roaming\npm-cache\_logs\2022-03-27T20_42_59_087Z-debug.log

C:\Users\Antunes\Desktop\Universidade\2021-2022\2º Semestre\Projeto 4  - Multimédia Interativo\Repo P4-painting-machine\Meta 2\Harmonograph>npm build

C:\Users\Antunes\Desktop\Universidade\2021-2022\2º Semestre\Projeto 4  - Multimédia Interativo\Repo P4-painting-machine\Meta 2\Harmonograph> dir~
'dir~' is not recognized as an internal or external command,
operable program or batch file.

C:\Users\Antunes\Desktop\Universidade\2021-2022\2º Semestre\Projeto 4  - Multimédia Interativo\Repo P4-painting-machine\Meta 2\Harmonograph>dir
 Volume in drive C is Windows-SSD
 Volume Serial Number is D61D-87F8

 Directory of C:\Users\Antunes\Desktop\Universidade\2021-2022\2º Semestre\Projeto 4  - Multimédia Interativo\Repo P4-painting-machine\Meta 2\Harmonograph

24/03/2022  15:27    <DIR>          .
24/03/2022  15:27    <DIR>          ..
24/03/2022  12:39    <DIR>          data
24/03/2022  16:53             2,566 Harmonograph.pde
24/03/2022  17:23               729 index.js
24/03/2022  15:23    <DIR>          node_modules
24/03/2022  15:23            14,682 package-lock.json
24/03/2022  15:37               377 package.json
               4 File(s)         18,354 bytes
               4 Dir(s)  101,498,056,704 bytes free

C:\Users\Antunes\Desktop\Universidade\2021-2022\2º Semestre\Projeto 4  - Multimédia Interativo\Repo P4-painting-machine\Meta 2\Harmonograph> node index.js
(node:13732) Warning: To load an ES module, set "type": "module" in the package.json or use the .mjs extension.
(Use `node --trace-warnings ...` to show where the warning was created)
C:\Users\Antunes\Desktop\Universidade\2021-2022\2º Semestre\Projeto 4  - Multimédia Interativo\Repo P4-painting-machine\Meta 2\Harmonograph\index.js:1
import express from "express";
^^^^^^

SyntaxError: Cannot use import statement outside a module
    at wrapSafe (internal/modules/cjs/loader.js:984:16)
    at Module._compile (internal/modules/cjs/loader.js:1032:27)
    at Object.Module._extensions..js (internal/modules/cjs/loader.js:1097:10)
    at Module.load (internal/modules/cjs/loader.js:933:32)
    at Function.Module._load (internal/modules/cjs/loader.js:774:14)
    at Function.executeUserEntryPoint [as runMain] (internal/modules/run_main.js:72:12)
    at internal/main/run_main_module.js:17:47

C:\Users\Antunes\Desktop\Universidade\2021-2022\2º Semestre\Projeto 4  - Multimédia Interativo\Repo P4-painting-machine\Meta 2\Harmonograph>node --experimental-modules index.js
PDF Printing Service listening on port 3000
```