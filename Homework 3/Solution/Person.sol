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

    /* welfare subsidy */
    uint state_subsidy;

    constructor(address ma, address fa) {
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

    //#region Echidna tests ----------------------------------------------------

    function echidna_symmetryMarriage() public view returns (bool) {
        if (!isMarried)
            return true;
        Person sp = Person(address(spouse));
        return sp.getSpouse() == address(this);

    }

    function echidna_spouse_address_consistency() public view returns (bool) {
        if (!isMarried)
            return spouse == address(0);
        return spouse != address(0);
    }

    //#endregion ---------------------------------------------------------------
}
 