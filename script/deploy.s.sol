// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../lib/forge-std/src/Script.sol";
import "../contracts/Diamond.sol";
import "../contracts/facets/DiamondLoupeFacet.sol";
import "../contracts/facets/AssetbuyingFacet.sol";
import "../contracts/interfaces/IDiamondCut.sol";
import "../contracts/facets/DiamondCutFacet.sol";
import "../contracts/facets/OwnershipFacet.sol";
import "../lib/forge-std/src/Vm.sol";

contract DiamondDeployer is Script, IDiamondCut {
    //contract types of facets to be deployed
    Diamond diamond;
    DiamondCutFacet dCutFacet;
    DiamondLoupeFacet dLoupe;
    OwnershipFacet ownerF;
    Assetbuyingfacet AssetF;


   address deployer =  0x7379ec8392c7684cecd0550A688D729717EBBB01;
    function run() public {
        uint256 key = vm.envUint("private_key");
        vm.startBroadcast(key);
        //deploy facets
        dCutFacet = new DiamondCutFacet();
        diamond = new Diamond(deployer, address(dCutFacet));
        dLoupe = new DiamondLoupeFacet();
        ownerF = new OwnershipFacet();
        AssetF  = new Assetbuyingfacet();

        //upgrade diamond with facets

        //build cut struct
        FacetCut[] memory cut = new FacetCut[](3);

        cut[0] = (
            FacetCut({
                facetAddress: address(dLoupe),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("DiamondLoupeFacet")
            })
        );

        cut[1] = (
            FacetCut({
                facetAddress: address(ownerF),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("OwnershipFacet")
            })
        );

                cut[2] = ( FacetCut({
            facetAddress: address(AssetF),
            action: FacetCutAction.Add,
            functionSelectors: generateSelectors("Assetbuyingfacet")
        }));

        
        IDiamondCut(address(diamond)).diamondCut(cut, address(0x0), "");
        DiamondLoupeFacet(address(diamond)).facetAddresses();
         vm.stopBroadcast();

        console.log(address(dCutFacet));
        console.log(address(diamond));
        console.log(address(dLoupe));
        console.log(address(ownerF));
        console.log(address(AssetF));
    }

    function generateSelectors(string memory _facetName)
        internal
        returns (bytes4[] memory selectors)
    {
        string[] memory cmd = new string[](3);
        cmd[0] = "node";
        cmd[1] = "scripts/genSelectors.js";
        cmd[2] = _facetName;
        bytes memory res = vm.ffi(cmd);
        selectors = abi.decode(res, (bytes4[]));
    }
    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external override {}


}
