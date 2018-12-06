// export LD_PRELOAD=/usr/lib/libswipl.so
// export LD_PRELOAD=/usr/lib64/swipl-7.2.3/lib/x86_64-linux/libswipl.so.7.2.3
// node: symbol lookup error: /usr/lib/swi-prolog/lib/amd64/socket.so: undefined symbol: PL_new_atom
// node --use_strict app.js

const swipl = require('swipl');
swipl.call('consult(trainscheduling)'); // consult the prolog file

// -----------------------------  HELPER FUNCTIONS -------------------------------- //
function expand1d(arr) {
    var ret = [];
    while(arr != '[]'){
        ret.push(arr.head);
        arr = arr.tail;
    }
    return ret;
}

function expand2d(arr){
    var ret = [];
    while(arr != '[]'){
        ret.push(expand1d(arr.head));
        arr = arr.tail;
    }
    return ret;
}

function expand3d(arr){
    var ret = [];
    while(arr != '[]'){
        ret.push(expand2d(arr.head));
        arr = arr.tail;
    }
    return ret;
}


function toString2dArray(arr){
    var ret = '[';
    for(var i = 0; i < arr.length; i++){
        if(i != 0) ret += ','
        ret = ret + '[';
        ret += arr[i];
        ret = ret + ']';
    }
    ret += ']';
    return ret;
}

function toString1dArray(arr){
    return '[' +  arr + ']';
}

// --------------------------  END OF HELPER FUNCTIONS ----------------------------- //


var cors = require('cors')
var bodyParser = require('body-parser')
var express = require('express')

var app = express()
app.use(cors())

app.use(bodyParser.urlencoded({ extended: false }))
app.use(bodyParser.json())
var port = process.env.PORT || 3000;

app.listen(port);
console.log('Server started! At http://localhost:' + port);

app.post('/getPlan', function (req, res) {

    var cntNodes = req.body.x;
    var adjMat = req.body.y;
    var cntMat = req.body.z;
    var startStations = req.body.s1;
    var endStations = req.body.s2;
    var startTimes = req.body.r;
    var dueTimes = req.body.d;

    // adding the adjMat predicate
    var adjMatString = toString2dArray(adjMat);
    var adjMatPredicate = 'assertz(mat('+adjMatString+'))';
    swipl.call(adjMatPredicate)

    // adding the cntMat predicate
    var cntMatString = toString2dArray(cntMat);
    var cntMatPredicate = 'assertz(cntMat('+cntMatString+'))';
    swipl.call(cntMatPredicate);

    // adding cntNodes predicate
    swipl.call('assertz(maxNodes('+ cntNodes + '))');

    // calling the main predicate to solve the problem
    var solveProblemPredicate = 'solveProblem(' + toString1dArray(startStations) +
                                ', ' + toString1dArray(endStations) +
                                ', ' + toString1dArray(startTimes) +
                                ', ' + toString1dArray(dueTimes) + 
                                ', Plan, TotalDelay)';
    var ret = swipl.call(solveProblemPredicate);

    // removing the added predicates
    swipl.call('retractall(mat(_))');
    swipl.call('retractall(cntMat(_))');
    swipl.call('retractall(maxNodes(_))');

    res.send(expand3d(ret.Plan));
  })
