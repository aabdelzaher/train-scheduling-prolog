This is a train scheduling web application. The server is implemented using nodejs while the scheduling logic is implemented using Prolog.

To run the program install swi-prolog in the same folder as the project then:
1- Install the needed dependencies using ``` npm install ```.
2- Run the server using ```node --use_strict app.js```

If the following error occured:
```
node: symbol lookup error: /usr/lib/swi-prolog/lib/amd64/socket.so: undefined symbol: PL_new_atom
```
run the following command and rerun the server.
```
export LD_PRELOAD=/usr/lib/libswipl.so
```
