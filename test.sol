// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./truc.sol"; // Assurez-vous d'importer le contrat SimpleToken correctement

contract MyContract {
    MyToken token; // Utilisez le type du contrat SimpleToken ici
    
    constructor() {
        address tokenAddress = 0x37bE2f112db981497b2Ac8f5e42d8a36130352C5; // Adresse du contrat SimpleToken déployé
        token = MyToken(tokenAddress); // Instanciez le contrat SimpleToken avec l'adresse fournie
    }
    
    function transferTokens() external {
        address toAddress = 0x8bE20acf0113C39962c1E285ED6648EaE0270699;
        uint256 amount = 1000;
        
        token.transfer(toAddress, amount);
    }
}
