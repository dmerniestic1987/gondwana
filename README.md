# Gondwana
Este proyecto contiene la lógica para registar y realizar los pagos de las apuestas en la plataforma Betex. 

El proyecto define un nuevo token ERC-20 llamado Betex Token (BTX) con 18 decimales.

## Dependencias
Es necesario instalar: 
-[web3j](https://web3j.io/) para comunicar java con los smart contracts que se ejecutan en EVM.


## Instalación del proyecto
Para instalar el proyecto primero debe realizar: 
```
npm install
```

## Copilación del proyecto
### Copilación de Smart Contracts
Los smart contracts del proyecto fueron desarrollados con el lenguaje Solidity.
Para compilar los contratos: 
```
npm run truffle-compile
```

### Generación de clases java
La plataforma Betex utiliza algunos componentes desarrollados en Java y la aplicación móvil 
está desarrollada con android nativo. Para utilizar los contratos inteligentes con tecnologías que utilicen java es necesario crear unas clases a partir de las ABI de los contratos.
Las clases se generar en el directorio build/java-classes

```
npm run gen-java
```
## Ejecución de test unitarios
Los test unitarios del proyecto se pueden ejecutar con: 
```
npm run test
```
## Deploy de los contratos
### Deploy en localhost con ganache-cli
Para el área de desarrollo local se utiliza **ganache-cli** como blockhain y se pueden deployar
contratos para probar las aplicaciones móviles y web apuntando a: http://localhost:8545
```
npm run ganache-cli
npm run truffle-migrate-dev
```

### Deploy a redes de tesnet
Actualmente se puede deployar el contrato a las siguientes redes de testnet:
*Rinkeby
*Ropsten
*POA Sokol
*RSK Testnet
Los detalles los puede apreciar en la sección *scripts* de **package.json**
```
npm run truffle-migrate-rinkeby
npm run truffle-migrate-ropsten
npm run truffle-migrate-poa-sokol-testnet
npm run truffle-migrate-rsk-testnet
```
## Contratos en testnet
Actualmente la versión 0.4 está deployada en 2 redes de testnet: Sokol (POA) y Rinkeby (Ethereum).

### Ethereum Rinkeby - Testnet
BetexToken: [0x4459C08d375254653aDc0546Efe7627A9F55fC19] (https://rinkeby.etherscan.io/address/0x4459C08d375254653aDc0546Efe7627A9F55fC19)
BetexSelfExcluded: [0x5aC163aEDfb8E5e404eD070Bf3951aE7Da408d85] (https://rinkeby.etherscan.io/address/0x5aC163aEDfb8E5e404eD070Bf3951aE7Da408d85)
BetexMobileGondwana: [0x0C4152a4D8d466dc280ee6569e729602466B120B] (https://rinkeby.etherscan.io/address/0x0C4152a4D8d466dc280ee6569e729602466B120B)
BetexLaurasiaGondwana: [0x22F831C4E38d876b246B368C14e76001A0D2dd46] (https://rinkeby.etherscan.io/address/0x22F831C4E38d876b246B368C14e76001A0D2dd46)
BetexSettings: [0xB43CbEd40bd711B72221358F39a2F61C52BAa577] (https://rinkeby.etherscan.io/address/0xB43CbEd40bd711B72221358F39a2F61C52BAa577)

### POA SOKOL - Testnet
BetexToken: [0x7E05C42Fd1ba071128afd38978E91Fde78712FF7] (https://blockscout.com/poa/sokol/address/0x7e05c42fd1ba071128afd38978e91fde78712ff7)
BetexSelfExcluded: [0x02D7D0CC599D19332cf8ED42b8C5e1bEF9cE19FA] (https://blockscout.com/poa/sokol/address/0x02D7D0CC599D19332cf8ED42b8C5e1bEF9cE19FA)
BetexMobileGondwana: [0xcD302630700f0D857EC30D02c16Bb62BFACb6B6a] (https://blockscout.com/poa/sokol/address/0xcD302630700f0D857EC30D02c16Bb62BFACb6B6a)
BetexLaurasiaGondwana: [0x60942DE4C41053e40f6Ff4eed16f778dB06760bB] (https://blockscout.com/poa/sokol/address/0x60942DE4C41053e40f6Ff4eed16f778dB06760bB)
BetexSettings: [0x0b6E99f9B328D05F2AD96c31b7EE82bEa82E2C2C] (https://blockscout.com/poa/sokol/address/0x0b6E99f9B328D05F2AD96c31b7EE82bEa82E2C2C)
