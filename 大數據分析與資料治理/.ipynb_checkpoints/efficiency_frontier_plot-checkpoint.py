# 一般風險計算
def efficiency_frontier_self(data,plt=True):
    import numpy as np
    import pandas as pd
    from pypfopt import risk_models
    from pypfopt import expected_returns
    from pypfopt.efficient_frontier import EfficientFrontier
    from pypfopt import cla #package tell to plot by cla package
    import matplotlib.pyplot as plt
    mu = expected_returns.mean_historical_return(data)#
    S = risk_models.sample_cov(data)
    ef = EfficientFrontier(mu, S,weight_bounds=(0, 1))
    weight=ef.max_sharpe()
    weight=pd.DataFrame(weight.values(),index=weight.keys(),columns=['weights'])
    cov=np.sqrt(np.diag(ef.cov_matrix))#計算風險
    ret=ef.expected_returns#計算報酬
    np.random.seed(1000)
    cut=weight[weight == 0].iloc[np.random.randint(0,len(weight[weight == 0]),10)].index    
    notcut=weight[weight != 0].dropna().index
    tickers=list(cut)+list(notcut)
    
    data_tickers=data[tickers]
    mu = expected_returns.mean_historical_return(data_tickers)#
    S = risk_models.sample_cov(data_tickers)   
    c=cla.CLA(mu, S,weight_bounds=(0, 1))# grab the ef from CLA function
    try:
        EF=c.efficient_frontier(points=100)#grab the 25 points  on default=100
    except:c.efficient_frontier(points=100)
    mus, sigmas, weights = c.frontier_values
    
    
    data_notcut=data[notcut]
    mu = expected_returns.mean_historical_return(data_notcut)#
    S = risk_models.sample_cov(data_notcut)   
    c=cla.CLA(mu, S,weight_bounds=(0, 1))# grab the ef from CLA function
    weight=c.max_sharpe()#grabe the optimal weights
    EF=c.efficient_frontier(points=25)#grab the 25 points  on default=100
    #obtain the optimal ret,risk from .performance()
    #grab points values, mus sigmas, weights
    #mus, sigmas, weights = c.frontier_values
    optimal_ret, optimal_risk, _ = c.portfolio_performance(verbose=True)
    cov_c=np.sqrt(np.diag(c.cov_matrix))#計算風險
    ret_c=c.expected_returns#計算報酬
    
    #作圖
    try:
        plt.rcParams['font.family'] = ['AR PL UMing CN']
    except:
        plt.rcParams['font.sans-serif'] = ['Noto Sans CJK TC']
    fig, ax = plt.subplots()
    #plot efficient frontier
    ax.plot(sigmas,mus,label='EF')#效率曲畫線
    #plot assets
    #the diagnal of the matrix is the self variance
    ax.scatter(cov,ret,s=30,color="b",label="assets",)#畫出每個股票的點
    ax.scatter(cov_c,ret_c,s=30,color="r",label="assets",)#畫出有權重的股票的點
    
    #plot optimal point#標記出最適頭組的點
    ax.scatter(optimal_risk, optimal_ret, marker="x", s=100, color="r", label="optimal")                
    ax.legend()#legend
    #x and y axis
    ax.set_xlabel("Volatility")
    ax.set_ylabel("Return")
    plt.show()
    bestweights=c.clean_weights()
    return pd.DataFrame(bestweights.values(),index=bestweights.keys(),columns=['weights'])



if __name__ == '__main__':
    from pypfopt import risk_models
    from pypfopt import expected_returns
    from pypfopt.efficient_frontier import EfficientFrontier
    import numpy as np
    import pandas as pd
    
    bestweights=efficiency_frontier_self(prices)
    print(bestweights)