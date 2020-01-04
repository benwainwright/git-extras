command! CheckoutBranch call gitExtras#checkout#branch()
command! CheckoutPR call gitExtras#checkout#pr()
command! CreatePR call gitExtras#pr#create() 
command! SubmitPR call gitExtras#pr#submit()
