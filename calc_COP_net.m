function [COP_net] = calc_COP_net(COP_l ,COP_r, GRFz_l, GRFz_r)
    COP_net = COP_l * GRFz_l / (GRFz_l + GRFz_r + 1e-8) + COP_r * GRFz_r / (GRFz_l + GRFz_r + 1e-8);
end