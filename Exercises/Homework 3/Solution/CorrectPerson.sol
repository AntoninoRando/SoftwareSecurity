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
        require(new_spouse != address(0), "New spouse cannot be zero address");
        require(new_spouse != address(this), "Cannot marry self");
        require(new_spouse != spouse, "Already married to this address");

        if (isMarried)
            divorce();

        spouse = new_spouse;
        isMarried = true;

        Person marriedPerson = Person(new_spouse);
        if (marriedPerson.getSpouse() != address(0)) {
            if (marriedPerson.getSpouse() == address(this)) return;
            marriedPerson.divorce();
        }
        marriedPerson.marry(address(this));
    }

    function divorce() public {
        require(isMarried, "Not married");
        require(spouse != address(0), "Spouse is zero address");

        Person oldSpouse = Person(address(spouse));
        
        spouse = address(0);
        isMarried = false;

        if (oldSpouse.getSpouse() == address(this))
            oldSpouse.divorce();
    }

    function haveBirthday() public {
        age++;
    }

    function setSpouse(address sp) public {
        require(sp != address(this), "Spouse cannot be self");
        if (isMarried)
            require(sp != address(0), "If married cannot set spuse to zero address");
        else
            require(sp == address(0), "If not married the only spouse can be zero address");
        
        spouse = sp;
    }
    
    // I've added the view modifies because it is a read-only function. This is
    // also useful to declare the echidna test as a view function.
    function getSpouse() public view returns (address) {
        return spouse;
    }
}

contract TestPerson is Person {
    constructor() Person(
        address(0x0000000000000000000000000000000000000001), 
        address(0x0000000000000000000000000000000000000002)
    ) {}

    //#region Echidna tests ----------------------------------------------------

    function echidna_symmetricMarriage() public view returns (bool) {
        if (!isMarried) return true;
        return Person(address(spouse)).getSpouse() == address(this);

    }

    function echidna_spouseAddressConsistency() public view returns (bool) {
        return isMarried? spouse != address(0) : spouse == address(0);
    }

    function echidna_notSelfMarried() public view returns (bool) {
        return spouse != address(this);
    }

    //#endregion ---------------------------------------------------------------
}