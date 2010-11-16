{
Trabalho final de MATA37 - Equipe 1: Jean, Luisa e Nanci
Projeto: Combate
}

program stratego;
uses CRT;

type
   no_pecas = ^pecas;
   pecas  = record {lista de peças}
               nome    : string[13];
               rank    : integer; {rank da peça - vai de 0 a 11}
               qtde    : integer;
               jogador : integer;
               prox    : no_pecas;
            end;       
   
var
   jog1, jog2, lago   : no_pecas;
   tabuleiro      : array [1..10, 1..10] of no_pecas;
   controle_pecas : array [0..11] of integer;
   n              : integer;
   
{Criação da lista de peças}
procedure lista_pecas(var inicio : no_pecas; nome : string; rank : integer);
var aux1, aux2 : no_pecas;
begin
   new(aux1);
   aux1^.nome := nome;
   aux1^.rank := rank;
   aux1^.qtde := 0; {quantidade posicionada de peças -> começa com 0}
   if (inicio = nil) then
      inicio := aux1
   else
   begin
      aux2 := inicio;
      while (aux2^.prox <> nil) do
         aux2 := aux2^.prox;
      aux2^.prox := aux1;
   end;
end; { lista_pecas }

{O procedimento a seguir insere os dados das peças do jogo na lista}
procedure dados_pecas;
begin
   lista_pecas(inicio, 'bomba', 0);
   lista_pecas(inicio, 'espiao', 1);
   lista_pecas(inicio, 'soldado', 2);
   lista_pecas(inicio, 'cabo-armeiro', 3);
   lista_pecas(inicio, 'sargento', 4);
   lista_pecas(inicio, 'tenente', 5);
   lista_pecas(inicio, 'capitao', 6);
   lista_pecas(inicio, 'major', 7);
   lista_pecas(inicio, 'coronel', 8);
   lista_pecas(inicio, 'general', 9);
   lista_pecas(inicio, 'marechal', 10);
   lista_pecas(inicio, 'bomba', 11);
end; { dados_pecas }

{Procedimento para preencher os vetores dos jogadores com as quantidades de cada peça -> as funções devem alterar esse valor}
procedure pecas_jogadores;
begin
   controle_pecas[0] := 1;
   controle_pecas[1] := 1;
   controle_pecas[2] := 8;
   controle_pecas[3] := 5;
   controle_pecas[4] := 4;
   controle_pecas[5] := 4;
   controle_pecas[6] := 4;
   controle_pecas[7] := 3;
   controle_pecas[8] := 2;
   controle_pecas[9] := 1;
   controle_pecas[10] := 1;
   controle_pecas[11] := 6;
end; { pecas_jogadores }


procedure preenche_lago;
begin
   tabuleiro[5][3] := lago;
   tabuleiro[5][4] := lago;
   tabuleiro[6][3] := lago;
   tabuleiro[6][4] := lago;
   tabuleiro[5][7] := lago;
   tabuleiro[5][8] := lago;
   tabuleiro[6][7] := lago;
   tabuleiro[6][8] := lago;
end; { preenche_lago }

procedure imprime_tabuleiro;
var i, j : integer;
begin
   for i := 1 to 10 do
   begin
      for j := 1 to 10 do
         if (tabuleiro[i][j] = nil) then
            write('__ ')
         else
            if (tabuleiro[i][j] = lago) then
               write('XX ')
            else
               write(tabuleiro[i][j]^.rank:2, ' ');
      writeln;
   end;
end; { imprime_tabuleiro }

{Explicações/Adionais:

No jogo, na hora de dispor as peças no tabuleiro e mover as peças é usada a lista e a lista passa a referencia para o vetor de cada jogador. Então na função de dispor as peças e de mover as peças é necessário uma variavel auxiliar do tipo no_pecas (ponteiro para a lista).

Pensei em relação as configurações da peça no tabuleiro:
1 - um procedimento com case pra imprimir e chamar as opções
2 - uma função para disposição das peças, que pegaria o valor do case como parametro e mandaria a disposicao que o usuario escolhesse ou um procedimento para cada disposicao e o case chamaria o procedimento correspondente.
lembrando, são 40 peças... talvez fique grande demais em uma função só, ou não.. ainda não sei e aceito sugestões.

Ja ia esquecendo... a bomba não entra no vetor de peças dos jogadores. Como é só uma, não ataca, não mata e não move é desnecessário para o objetivo.
}

{Procedimento para dispor as peças de determinado jogador (a ou b) no tabuleiro}
procedure dispor_pecas(x : integer );
var q, linha, coluna, rank : integer;
   cheq                    : boolean;
   aux                     : no_pecas;
begin
   q := 0;
   repeat
      aux := inicio;
      writeln('Digite o rank de uma peça. Use 11 para bomba e 0 para bandeira');
      readln(rank);
      {Se o jogador digitar um rank inválido ele terá que digitar novamente}
      while (controle_pecas[x][rank] = 0) or (rank < 0) or (rank > 12) do {XXX: logica de verifica se quant disp é 0}
      begin
         writeln('Peça indisponível. Por favor, digite novamente o rank');
         readln(rank);
      end;
      {A auxiliar vai percorrer a lista até achar o rank correspondente}
      while (aux^.rank <> rank) and (aux <> nil) do
      begin
         aux := aux^.prox;
      end;
      cheq := false; {Variável para verificar se o jogador digitou uma posição válida no tabuleiro}
      repeat   
         writeln('Digite a posição da peça');
         readln(linha, coluna);
         if (x = 1) then
         begin
            if (linha < 0) or (linha > 4) then
               writeln('Posição inválida')
            else
               cheq := true;
         end
         else
            if (linha > 20) or (linha < 17) then
               writeln('Posição inválida')
            else
               cheq := true;
      until (cheq = true);
      tabuleiro[linha][coluna] := aux;
      dec(controle_pecas[x][rank]); {XXX: Incrementa o número de peças já alocadas na lista do jogador}
      inc(q);
      imprime_tabuleiro;
   until (q = 2); {XXX: q = 40}
end; { dispor_pecas }

procedure remove_peca(peca : no_pecas, j : integer);
var r : integer;
begin
   r := peca^.rank;
   {Decrementa o vetor que diz a quantidade de cada peça}
   dec(controle_pecas[j][r]) {XXX: ajeitar tudo}
end; { remove_peca }

{
Função de combate: ela checa qual peça ganha no combate direto
Valores de retorno:
0 para empate -> exclusão das duas peças
1 para vitória do atacante -> exclusão do atacado
-1 para vitória do atacado -> exclusão do atacante
}

function combate(linha1, coluna1, linha2, coluna2 : integer) : integer;
var atacante, atacado : no_pecas;
begin
   atacante := tabuleiro[linha1][coluna1];
   atacado := tabuleiro[linha2][coluna2];
   {Exceção 1: cabo-armeiro desarma a bomba}
   if (atacante^.rank = 3) and (atacado^.rank = 11) then
   begin
      remove_peca(atacado);
      tabuleiro[linha2][coluna2] := tabuleiro[linha1][coluna1];      
   end
   else
      {Exceção 2: se o espião atacar o marechal ele ganha}
      if (atacante^.rank = 1) and (atacado^.rank = 10) then
      begin
         remove_peca(atacado);
         tabuleiro[linha2][coluna2] := tabuleiro[linha1][coluna1];
      end
      else
         {Regra: ganha quem tiver maior rank}
         if (atacante^.rank > atacado^.rank) then
         begin
            remove_peca(atacado);
            tabuleiro[linha2][coluna2] := tabuleiro[linha1][coluna1];
            combate := 1;
         end
         else
            if (atacante^.rank = atacado^.rank) then
            begin
               remove_peca(atacado);
               remove_peca(atacante);
               tabuleiro[linha2][coluna2] := nil;
               combate:=0;
            end
            else
            begin
               remove_peca(atacante);
               combate:=-1;
            end;
   {O lugar da peça atacante sempre vai ficar vazio -> ou ela toma outro lugar ou ela é derrotada}
   tabuleiro[linha1][coluna1] := nil;
end; { combate }

{Procedimento para cuidar dos movimentos das peças -> linha_atual e coluna_atual são as coordenadas da peça, j é o inteiro que representa o jogador 1 ou 2, linha e coluna são as coordenadas que o jogador pretende mover a peça}
function move_peca(linha_atual, coluna_atual, linha, coluna, j : integer) : boolean;
var
begin
   {Regra de movimento de 1 casa horizontal ou vertical válida para todas as peças, exceto: 0, 2 e 11}
   if (tabuleiro[linha_atual][coluna_atual]^.rank <> 2) then
      if ((linha = linha_atual + 1) and (coluna = coluna_atual)) or ((linha = linha_atual -1) and (coluna = coluna_atual)) or ((coluna = coluna_atual + 1) and (linha = linha_atual)) or ((coluna = coluna_atual - 1) and (linha = linha_atual)) then
         {Se o lugar estiver vazio...}
         if (tabuleiro[linha][coluna] = nil) then
         begin
            tabuleiro[linha][coluna] := tabuleiro[linha_atual][coluna_atual];
            tabuleiro[linha_atual][coluna_atual] := nil;
         end
         else
            

{Programa principal}
begin
   {preenchimento da área do lago... como temos uma matriz de ponteiros, temos um ponteiro para o lago ser inserido no tabuleiro}
   new(lago);
   lago^.rank := -1;
   lago^.nome := 'lago';
   preenche_lago;

   dados_pecas;
   pecas_jogadores;
   n := 1;
   dispor_pecas(n);
   imprime_tabuleiro;
end.