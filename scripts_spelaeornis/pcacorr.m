function [coeff, score, latent, expl] = pcacorr(n)
    V = cov(n);
    SD = sqrt(diag(V));
    R = V./(SD*SD');
    [coeff, latent, expl] = pcacov(R);
    score = (zscore(n))*coeff;
end