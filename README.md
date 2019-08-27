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
BetexToken: [0x4A3e76d5aAEEE68eB1190207E234C35D27DBDAA2] (https://rinkeby.etherscan.io/address/0x4A3e76d5aAEEE68eB1190207E234C35D27DBDAA2)
BetexSelfExcluded: [0x176D291324d21B8a0cfE6b4eC3B271e6Aad909FA] (https://rinkeby.etherscan.io/address/0x176D291324d21B8a0cfE6b4eC3B271e6Aad909FA)
BetexMobileGondwana: [0x1e4D32a1EA1503ba6a6af338F91F821e561503af] (https://rinkeby.etherscan.io/address/0x1e4D32a1EA1503ba6a6af338F91F821e561503af)
BetexLaurasiaGondwana: [0x0dAB1918277CD206D29E4601F2057136D3255816] (https://rinkeby.etherscan.io/address/0x0dAB1918277CD206D29E4601F2057136D3255816)
BetexSettings: [0x82c6d1fdA7c4f55AC37466820b2598978B41113a] (https://rinkeby.etherscan.io/address/0x82c6d1fdA7c4f55AC37466820b2598978B41113a)

### POA SOKOL - Testnet
BetexToken: [0x047cb89D54c0cD25739a4b6CC486E8aCcD080cDc] (https://blockscout.com/poa/sokol/address/0x047cb89D54c0cD25739a4b6CC486E8aCcD080cDc)
BetexSelfExcluded: [0x9E3DF1843bE5Cb87848b215ce9742471E40EA5C6] (https://blockscout.com/poa/sokol/address/0x9E3DF1843bE5Cb87848b215ce9742471E40EA5C6)
BetexMobileGondwana: [0xC9F30D8e30D19cf5D7EA2052fa0D087c94028278] (https://blockscout.com/poa/sokol/address/0xC9F30D8e30D19cf5D7EA2052fa0D087c94028278)
BetexLaurasiaGondwana: [0x1826ab56d2a7D79052C9A01874970eC30897a18E] (https://blockscout.com/poa/sokol/address/0x1826ab56d2a7D79052C9A01874970eC30897a18E)
BetexSettings: [0xD8D51C45029Da9E95a4722C6BCB2EC1284f4218D] (https://blockscout.com/poa/sokol/address/0xD8D51C45029Da9E95a4722C6BCB2EC1284f4218D)
