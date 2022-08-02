function [data, Spacing, Thickness] = VolumeMatRead(filename)
    inp = load(filename);
    f = fields(inp);
    % Volume Pixel Value (HU)
    data = inp.(f{3});
    % Pixel Spacing
    Spacing = inp.(f{1});
    % SliceThinkness
    Thickness = inp.(f{2});

end