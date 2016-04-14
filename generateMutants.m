poly8 = @(x) x.^8 - 35.*x.^7 + 14.*x.^5 - 105.*x.^3 + 5.*x.^2 + 75.*x + 31
setenv('PYTHONPATH', [getenv('PYTHONPATH')' 'C:\Users\Kevin\Anaconda2\pymute'])
matmute('pchip', { { ( 1:0.1:10 ), poly8( 1:0.1:10 ), ( 2:0.01:5 ) } }, 1 )