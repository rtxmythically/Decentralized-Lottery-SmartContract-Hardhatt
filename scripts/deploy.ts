import { ethers, run } from "hardhat";
import { config as dotenvConfig } from "dotenv";

dotenvConfig();

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);

    const subscriptionId = process.env.CHAINLINK_SUBSCRIPTION_ID;
    if (!subscriptionId) {
        throw new Error("CHAINLINK_SUBSCRIPTION_ID not set in .env");
    }

    const Lottery = await ethers.getContractFactory("Lottery");
    const lottery = await Lottery.deploy(subscriptionId);

    const receipt = await lottery.deploymentTransaction()?.wait();
    if (!receipt) {
        throw new Error("Deployment transaction receipt not found");
    }

    console.log("Lottery deployed to:", lottery.target);

    // 等待 5 個區塊確認
    await lottery.deploymentTransaction()?.wait(5);

    // 驗證合約
    try {
        await run("verify:verify", {
            address: lottery.target,
            constructorArguments: [subscriptionId],
        });
        console.log("Contract verified successfully");
    } catch (error) {
        console.error("Verification failed:", error);
    }
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});