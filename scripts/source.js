const tokenAddressArg = args[0];
const amountArg = args[1];
const targetChainIdArg = args[2];
const payment = Functions.makeHttpRequest({
  url: `http://3.144.170.236:3000/pay`,
  headers: {
    "Content-Type": "application/json",
  },
  params: {
    tokenAddress: tokenAddressArg,
    amount: amountArg,
    targetChainId: targetChainIdArg,
  },
});
const paymentResponse = await payment;
if (paymentResponse.error) {throw Error("Request failed");}
return Functions.encodeString(`data : ${paymentResponse["data"]},status : ${paymentResponse["status"]}`);