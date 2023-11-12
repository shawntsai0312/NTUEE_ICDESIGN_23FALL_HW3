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
  * normal case : find min and max, the difference should be 4
  * 10,11,12,13,1 : directly determine it
* four of a kind checker
  * input four cards and determine if they are the same rank, parallel*5, if one of them is true, then it's true
* full house checker
  * combine three of a kind checker and one pair checker, parallel*10
* three of a kind checker
  * input three cards and determine if they are the same rank, parallel*10
  * if the output of full house checker and four of a kind checker are both false, then it's true
* two pair checker
* one pair checker
