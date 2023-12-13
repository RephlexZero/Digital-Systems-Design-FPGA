function [ IMG ] = ImageConvert( filename )

    RGB = imread(filename);
    R = RGB(:,:,1);
    RED = double(R);
    RED = RED*7/255;
    RED = round(RED);
    RED = dec2bin(RED);
    G = RGB(:,:,2);
    GREEN = double(G);
    GREEN = GREEN*7/255;
    GREEN = round(GREEN);
    GREEN = dec2bin(GREEN);
    B = RGB(:,:,3);
    BLUE = double(B);
    BLUE = BLUE*3/255;
    BLUE = round(BLUE);
    BLUE = dec2bin(BLUE);
    IMG = [RED, GREEN, BLUE]; 
    IMG = dec2hex(bin2dec(IMG));
    HEX = fopen('DATA_test.mif','w');
    fprintf(HEX, 'WIDTH=16;\r\nDEPTH=16384;\r\nADDRESS_RADIX=HEX;\r\nDATA_RADIX=HEX;\r\n\r\nCONTENT BEGIN\r\n');
    for n = 1:15000
        TH = num2str(IMG(2*n-1,:));
        BH = num2str(IMG(2*n,:));
        fprintf(HEX, '%04X : %2s%2s;\r\n', n , TH , BH);
        n = n + 1;
    end
    fprintf(HEX, '[3A99..3fff]  :   0000;\r\nEND\r\n;');
    fprintf(HEX, '-- Produced by: Conners Converter');
    fclose(HEX);
end
