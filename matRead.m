function data = matRead(filename)
    inp = load(filename);
    f = fields(inp);
    data = inp.(f{1});
    %data = imbinarize(data);
end