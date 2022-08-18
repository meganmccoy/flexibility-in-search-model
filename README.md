# flexibility-in-search-model

Estimating a search model with workplace flexibility 

(Started as modifying Field Paper model to study workplace flexibility)

## Model Set-up
- Search model in stationary, continuous time.
- Individuals $i$ are employed with utility $u(w, k; \gamma) = w + \gamma f$ or unemployed with flow (dis)utility $b$. The utility weight of flexibility, $\gamma$, can be any real number.
- Firms are endowed with flexibility level $f \in F = \{0, 1, 2, ... F\}$ in which they offer employees flexibility $f$ at cost $c(f)$ where $c(0) = 0$. The probability of a firm being type $f$ is $p_f$ where $p_f>0$  $\forall f$ and $\sum_f p_f = 1$. 
- Firms have a production function $y(x,f)$ of some numeraire good and maximize profits $\pi(x,f)$ subject to the cost of labor $w$ and the cost of providing flexibility $c(f)$, thus $\pi(x,f) = y(x,f) - w - c(f)$. We assume $y(x,f) = \zeta^f x$. 
- Unemployed individuals meet firms following Poisson process with parameter $\lambda$. With probability $p_f$ they have met with a firm of type $f$ and draw match-specific productivity $x \sim G(x)$. After observing the match-specific productivity, the wage $w$ is determined by Nash bargaining with parameter $\alpha$.
- Employed workers face a termination shock following a Poisson process with parameter $\eta$. 
- Individuals and firms share a common discount rate $\rho$.

## Data 
- American Time Use Survey (ATUS) 2017-18 
  - Leave Module for employed individuals' wages and flexibility level
    - Two binary measures of flexibility: schedule flexibility (able to change start/end times of work or not) and location flexibility (able to work from home or not)
  - Unemployed individuals' unemployment duration found by linking to 8th round CPS interview; duration = duration spell in 8th round + time between 8th round CPS and ATUS interview  
  
## See paper for more details
