



SELECT A.CODNEW, A.DOCUM, A.DATA, A.QUANTIDADE, A.VARIAVEL FROM MOV_CUSTO A INNER JOIN MOV_CON B ON A.REGISTRO = B.NRECNO
INNER JOIN PRODUCAO_ORDEM C ON B.CHAVE = C.CHAVE
WHERE A.DATA> = '07/01/2017' AND A.DATA <= '07/31/2017'
AND A.CODNEW = '21.0100.01.01 '
AND A.EMPRESA = 5


SELECT * FROM BUDGET_PLANO_VENDAS


---- CONSUMPTION
SELECT A.CODNEW, A.DOCUM, A.DATA, A.QUANTIDADE, A.VARIAVEL 
FROM MOV_CUSTO A
INNER JOIN MOV_CON B ON A.REGISTRO = B.NRECNO
INNER JOIN PRODUCAO_ORDEM C ON B.CHAVE = C.CHAVE
INNER JOIN EMPRESAS D ON ( B.COD_SER = D.M_CONS OR B.COD_SER = D.M_REJ_S )  AND D.CODIGO = B.EMPRESA
WHERE A.DATA> = '07/01/2017' AND A.DATA <= '07/31/2017'
AND A.CODNEW = '21.0100.01.01'
AND A.EMPRESA = 5




---- PRODUCTION
SELECT A.CODNEW, A.DOCUM, A.DATA, A.QUANTIDADE, A.VARIAVEL 
FROM MOV_CUSTO A
INNER JOIN MOV_CON B ON A.REGISTRO = B.NRECNO
INNER JOIN PRODUCAO_ORDEM C ON B.CHAVE = C.CHAVE
INNER JOIN EMPRESAS D ON ( B.COD_SER = D.M_PROD OR B.COD_SER = D.M_REJ_E )  AND D.CODIGO = B.EMPRESA
WHERE A.DATA> = '07/01/2017' AND A.DATA <= '07/31/2017'
AND A.EMPRESA = 5




