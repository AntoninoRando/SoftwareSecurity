pragma solidity ^0.8.22;
// SPDX-License-Identifier: UNLICENSED

contract Person {
    uint age;

    bool isMarried;

    /* Reference to spouse if person is married, address(0) otherwise */
    address spouse;

    address mother;
    address father;

    uint constant DEFAULT_SUBSIDY = 500;
    uint constant ELDERLY_SUBSIDY = 600;
    uint constant RETIREMENT_AGE = 65;

    /* welfare subsidy */
    uint state_subsidy;

    function initPerson(address ma, address fa) public {
        age = 0;
        isMarried = false;
        mother = ma;
        father = fa;
        spouse = address(0);
        state_subsidy = DEFAULT_SUBSIDY;
    }

    //We require new_spouse != address(0);
    function marry(address new_spouse) public {
        spouse = new_spouse;
        isMarried = true;
    }

    function divorce() public {
        Person sp = Person(address(spouse));
        sp.setSpouse(address(0));
        spouse = address(0);
        isMarried = false;
    }

    function haveBirthday() public {
        age++;
    }

    function setSpouse(address sp) public {
        spouse = sp;
    }

    // I've added the view modifies because it is a read-only function. This is
    // also useful to declare the echidna test as a view function.
    function getSpouse() public view returns (address) {
        return spouse;
    }

    //#region ECHIDNA PROPERTIES / PART 1 --------------------------------------
    function echidna_symmetricMarriage() public view returns (bool) {
        if (!isMarried || spouse == address(0)) return true;
        return Person(spouse).getSpouse() == address(this);
    }
    function echidna_spouseAddressConsistency() public view returns (bool) {
        return isMarried? spouse != address(0) : spouse == address(0);
    }
    function echidna_notSelfMarried() public view returns (bool) {
        return spouse != address(this);
    }
    //#endregion ---------------------------------------------------------------
    //#region ECHIDNA PROPERTIES / PART 2 --------------------------------------
    function echidna_rightSubsidy() public view returns (bool) {
        if (isMarried) return state_subsidy == DEFAULT_SUBSIDY * 70 / 100;
        return state_subsidy == (age < RETIREMENT_AGE ? 
                                DEFAULT_SUBSIDY : ELDERLY_SUBSIDY);
    }
    function echidna_validAge() public view returns (bool) {
        return age >= 0;
    }
    //#endregion ---------------------------------------------------------------
}

// contract TestPerson is Person {
//     constructor()
//         Person(
//             address(0x0000000000000000000000000000000000000001),
//             address(0x0000000000000000000000000000000000000002)
//         )
//     {}
// }
