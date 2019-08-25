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

