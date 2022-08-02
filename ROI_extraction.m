function Zout = ROI_extraction(X)
            
             Z1 = max(X,0);
             sz = size(Z1);
             Z = single(zeros(sz));
             Z1 = extractdata(Z1);

            for i = 1 : sz(end)
                Z0 = Z1(:,:,:,i);
                ZM = imbinarize(Z0, 0.001);
                ZMF = imfill(ZM, 'holes');

                Z0(~ZMF) = 0;
                Z(:,:,:,i) = Z0;
            end
            Zout = dlarray(Z);
end