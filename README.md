# IC Design 23Fall HW3
##### author : B10901176 蔡弘祥

#### Before Running
```shell
source ./tool.sh
```

#### How To Run
```shell
cd src
./check.sh
./sim.sh
```

#### Cases
|number  |cases          |
|--------|---------------|
|0       |high card      |
|1       |one pair       |
|2       |two pair       |
|3       |three of a kind|
|4       |straight       |
|5       |flush          |
|6       |full house     |
|7       |four of a kind |
|8       |straight flush |

* Ace cannot be in the middle of a straight or a straight flush
* degrade into a high card or a flush

* flush checker
  * the first two bits of all five cards should be the same
* straight checker
  * There are total 10 cases, each case has 5!(=120) possibilities
  * neighbor checker, rank difference = 1
    * 5 cards, 3 have 2 neighbors, 2 have 1 neighbor, with no ranks are the same (not onePairPossible)
  * 10,11,12,13,1 detecter
* identical 4 ranks checker
  * input four cards and determine if they are the same rank, parallel*5
  * if one of them is true, then it's 4 of a kind
* full house checker
  * combine three of a kind checker and one pair checker, parallel*10
* identical 3 ranks checker
  * input three cards and determine if they are the same rank, parallel*10
  * if the output of full house checker and four of a kind checker are both false, then it's true
* two pair checker
* one pair checker
