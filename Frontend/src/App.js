import React, { useEffect, useState } from 'react';
import twitterLogo from './assets/twitter-logo.svg';
import SelectCharacter from './Components/SelectCharacter';
import './App.css';
import { CONTRACT_ADDRESS } from './constants';
import myEpicGame from './utils/MyEpicGame.json';
import { ethers } from 'ethers';

// Constants
const TWITTER_HANDLE = 'thexovc';
const TWITTER_LINK = `https://twitter.com/${TWITTER_HANDLE}`;

const App = () => {
  const [currentAccount, setCurrentAccount] = useState(null);
  const [characterNFT, setCharacterNFT] = useState(null);

  const checkIfWalletIsConnected = async () => {
    try {
      const { ethereum } = window;

      if (!ethereum) {
        console.log('Make sure you have MetaMask!');
        return;
      } else {
        console.log('We have the ethereum object', ethereum);

        const accounts = await ethereum.request({ method: 'eth_accounts' });


        if (accounts.length !== 0) {
          const account = accounts[0];
          console.log('Found an authorized account:', account);
          setCurrentAccount(account);
        } else {
          console.log('No authorized account found');
        }
      }
    } catch (error) {
      console.log(error);
    }
  };

  const renderContent = () => {
    if (!currentAccount) {
      return (
        <div className="connect-wallet-container">
          <img
              src="https://64.media.tumblr.com/6c1967af3027b1cdd6aa75fa1377b006/b36d08ce44c8a82e-d7/s640x960/573890d602394521f8355cd783c1cf189fce32e3.gifv"
              alt="FlurryLand Landscape"
            />
          <button
            className="cta-button connect-wallet-button"
            onClick={connectWalletAction}
          >
            Connect Wallet To Get Started
          </button>
        </div>
      );
      /*
       * Scenario #2
       */
    } else if (currentAccount && !characterNFT) {
      return <SelectCharacter setCharacterNFT={setCharacterNFT} />;
    }
  };

  const connectWalletAction = async () => {
    try {
      const { ethereum } = window;

      if (!ethereum) {
        alert('Get MetaMask!');
        return;
      }

      const accounts = await ethereum.request({
        method: 'eth_requestAccounts',
      });

      console.log('Connected', accounts[0]);
      setCurrentAccount(accounts[0]);
    } catch (error) {
      console.log(error);
    }
  };

  const checkNetwork = async () => {
    try { 
      if (window.ethereum.networkVersion !== '5') {
        alert("Please connect to Goerli!")
      }
    } catch(error) {
      console.log(error)
    }
  }


  useEffect(() => {
    checkIfWalletIsConnected();

    const fetchNFTMetadata = async () => {
       console.log('Checking for Character NFT on address:', currentAccount);

      const provider = new ethers.providers
    }
    
  }, []);

  return (
    <div className="App">
      <div className="container">
        <div className="header-container">
          <p className="header gradient-text">⚔️ FurryLand Fighters ⚔️</p>
          <p className="sub-text">Team up to protect the FlurryLand!</p>
          {renderContent()}
         
        </div>
        <div className="footer-container">
          <img alt="Twitter Logo" className="twitter-logo" src={twitterLogo} />
          <a
            className="footer-text"
            href={TWITTER_LINK}
            target="_blank"
            rel="noreferrer"
          >{`built by @${TWITTER_HANDLE}`}</a>
        </div>
      </div>
    </div>
  );
};

export default App;
