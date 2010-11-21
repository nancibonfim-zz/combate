{
Trabalho final de MATA37 - Equipe 1: Jean, Luisa e Nanci
Projeto:Combate
}

program stratego;
uses CRT;

type
   no_pecas = ^pecas;
   pecas = record {lista de peças}
              nome    : string[13];
              rank    : integer; {rank da peça - vai de 0 a 11}
              qtde    : integer;
              jogador : integer;
              prox    : no_pecas;
           end;       
   
var
   jog1, jog2, lago : no_pecas;
   tabuleiro : array [1..10, 1..10] of no_pecas;
   controle_pecas : array [0..11] of integer;
   jogador, linha_atual, linha, coluna_atual, coluna : integer;
   
{Criação da lista de peças}
procedure lista_pecas(var inicio : no_pecas; nome : string; rank, jogador : integer);
var aux1, aux2 : no_pecas;
begin
   new(aux1);
   aux1^.nome := nome;
   aux1^.rank := rank;
   aux1^.jogador := jogador;
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
procedure dados_pecas(inicio : no_pecas; jogador : integer);
begin
   lista_pecas(inicio, 'bomba', 0, jogador);
   lista_pecas(inicio, 'espiao', 1, jogador);
   lista_pecas(inicio, 'soldado', 2, jogador);
   lista_pecas(inicio, 'cabo-armeiro', 3, jogador);
   lista_pecas(inicio, 'sargento', 4, jogador);
   lista_pecas(inicio, 'tenente', 5, jogador);
   lista_pecas(inicio, 'capitao', 6, jogador);
   lista_pecas(inicio, 'major', 7, jogador);
   lista_pecas(inicio, 'coronel', 8, jogador);
   lista_pecas(inicio, 'general', 9, jogador);
   lista_pecas(inicio, 'marechal', 10, jogador);
   lista_pecas(inicio, 'bomba', 11, jogador);
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

{Procedimento para alocar no tabuleiro o lago, que é uma área intransitável}
procedure preenche_lago;
begin
   new(lago);
   lago^.rank := -1;
   lago^.nome := 'lago';
   lago^.jogador := 0; 
   tabuleiro[5][3] := lago;
   tabuleiro[5][4] := lago;
   tabuleiro[6][3] := lago;
   tabuleiro[6][4] := lago;
   tabuleiro[5][7] := lago;
   tabuleiro[5][8] := lago;
   tabuleiro[6][7] := lago;
   tabuleiro[6][8] := lago;
end; { preenche_lago }

{Procedimento para impressão do tabuleiro -> Recebe o jogador como parâmetro para ocultar as peças do adversário}
procedure imprime_tabuleiro(jogador : integer);
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
               if (tabuleiro[i][j]^.jogador = jogador) then
                  write(tabuleiro[i][j]^.rank:2, ' ')
               else
                  write('# ');
         writeln;
   end;
end; { imprime_tabuleiro }

{Função para localizar o rank na lista, se ele for válido}
function acha_rank(inicio : no_pecas; rank : integer): no_pecas;
var aux : no_pecas;
begin
   aux := inicio;
   while (aux^.rank <> rank) and (aux <> nil) do
   begin
      aux := aux^.prox;
   end;
   acha_rank := aux;
end;

{Procedimento para dispor as peças de determinado jogador (a ou b) no tabuleiro}
procedure dispor_pecas(i:integer; inicio : no_pecas);
var q, linha, coluna, rank : integer;
   checagem                : boolean;
   aux                     : no_pecas;
begin                      
   q := 0; {Quantidade de peças dispostas... inicia com 0}
   repeat
      writeln('Digite o rank de uma peça. Use 11 para bomba e 0 para bandeira');
      readln(rank);
      aux := acha_rank(inicio, rank);
      {Se o jogador digitar um rank inválido ele terá que digitar novamente}
      while (aux = nil) or (aux^.qtde >= controle_pecas[rank]) do
      begin
         writeln('Peça indisponível. Por favor, digite novamente o rank');
         readln(rank);
         aux := acha_rank(inicio, rank);
      end;
      checagem := false; {Variável para verificar se o jogador digitou uma posição válida no tabuleiro}
      repeat
         writeln('Digite a posição da peça');
         readln(linha, coluna);
         if (aux^.jogador = 1) then
         begin
            if (linha < 0) or (linha > 4) then
               writeln('Posição inválida')
            else
               checagem := true;
         end
         else
            if (linha > 10) or (linha < 7) then
               writeln('Posição inválida')
            else
               checagem := true;
      until (checagem = true);
      tabuleiro[linha][coluna] := aux;
      inc(aux^.qtde); {Incrementa o número de peças já alocadas na lista do jogador}
      inc(q);
      imprime_tabuleiro(i);
   until (q = 2); {XXX: q = 40}
end; { dispor_pecas }

procedure remove_peca(peca : no_pecas);
begin
   {Decrementa o vetor que diz a quantidade de cada peça}
   dec(peca^.qtde);
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
      combate := 1;
   end
   else
      {Exceção 2: se o espião atacar o marechal ele ganha}
      if (atacante^.rank = 1) and (atacado^.rank = 10) then
      begin
         remove_peca(atacado);
         tabuleiro[linha2][coluna2] := tabuleiro[linha1][coluna1];
         combate := 1;
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

{Funçao verifica se lugar digitado é válido}
function valida_espaco(jogador, linha, coluna : integer): boolean;
var aux : boolean ;
begin
   aux := false;
   {1. espaço vazio}
   if (tabuleiro[linha][coluna] = nil) then
   begin
      writeln('Espaço vazio. Por favor, tente novamente.');
   end
   else
      {2. verifica se a peça é do próprio jogador}
      if (tabuleiro[linha][coluna]^.jogador <> jogador) then
         writeln('Peça inválida. Por favor, tente novamente.')
      else
      {3. verifica se a peça selecionada é móvel}
         if (tabuleiro[linha_atual][coluna_atual]^.rank = 0) or (tabuleiro[linha_atual][coluna_atual]^.rank = 11) then
         begin
            writeln('Peça imóvel. Por favor, tente novamente');
         end
         else
            aux := true;
   valida_espaco := aux;
end; { valida_espaco }   
   

{Função verifica se o movimento das peças é válido}
function valida_movimento(linha_atual, coluna_atual, linha, coluna : integer) : boolean;
var aux : boolean;
   rank : integer;
begin
   aux := false;
   rank := tabuleiro[linha_atual][coluna_atual]^.rank;
   if (linha > 0) and (linha <= 10) and (coluna > 0) and (coluna <= 10) then
   begin
      if ((linha = linha_atual + 1) and (coluna = coluna_atual)) or ((linha = linha_atual -1) and (coluna = coluna_atual)) or ((coluna = coluna_atual + 1) and (linha = linha_atual)) or ((coluna = coluna_atual - 1) and (linha = linha_atual)) then
         aux := true;
      {Regra de movimento de 1 casa horizontal ou vertical válida para todas as peças, exceto 2}
      if (rank = 2) then
      begin
         if (linha = linha_atual) then
         begin
            if (coluna <> coluna_atual) and (tabuleiro[linha][coluna] = nil) then
               aux := true;
         end
         else
            if (coluna = coluna_atual) then
            begin
               if (linha <> linha_atual) and (tabuleiro[linha][coluna] = nil) then
                  aux := true;
            end;
      end;
   end;
   valida_movimento := aux;
end; { valida_movimento }

{Procedimento para cuidar dos movimentos das peças -> linha_atual e coluna_atual são as coordenadas da peça, j é o inteiro que representa o jogador 1 ou 2, linha e coluna são as coordenadas que o jogador pretende mover a peça}

function move_peca(jogador, linha_atual, coluna_atual, linha, coluna : integer):boolean;
begin
   move_peca := valida_movimento(linha_atual, coluna_atual, linha, coluna);
   if (move_peca) then
   begin
      {Se o lugar estiver vazio...}
      if (tabuleiro[linha][coluna] = nil) then
      begin
         tabuleiro[linha][coluna] := tabuleiro[linha_atual][coluna_atual];
         tabuleiro[linha_atual][coluna_atual] := nil;
      end
      else
         combate(linha_atual, coluna_atual, linha, coluna);
   end
   else
      writeln('Movimento inválido. Por favor, tente novamente.');
end;
{ move_peca }

function final_jogo(jogador : integer) : boolean;
var aux : boolean;
   inicio : no_pecas;
begin
   {Verificar condições de final de jogo: adversário imóvel, se a última peça ataca foi a bandeira...}
   aux := false;
   final_jogo := aux;
end;

var
   final  : boolean;
   rodada : integer;
   
{Programa principal}
begin
   {preenchimento da área do lago... como temos uma matriz de ponteiros, temos um ponteiro para o lago ser inserido no tabuleiro}
   preenche_lago;
   {Aloca memória dos ponteiros dos jogadores}
   new(jog1);
   jog1^.jogador := 1;
   new(jog2);
   jog2^.jogador := 2;
   {Criação de lista para os dois jogadores}
   pecas_jogadores;
   dados_pecas(jog1, 1);
   dados_pecas(jog2, 2);
   {Dispõe peças para os dois jogadores}
   writeln('Vez do jogador 1');
   dispor_pecas(1,jog1); 
   writeln;
   
   clrscr;
   imprime_tabuleiro(2);
   writeln('Vez do jogador 2');
   dispor_pecas(2,jog2);

   jogador := 1;
   clrscr;
   imprime_tabuleiro(jogador);
   rodada := 0;
   
   {Inicio do jogo}
   repeat
      writeln('Vez do jogador ', jogador);
      writeln('Informe as coordenadas da peça que deseja mover');
      readln(linha_atual, coluna_atual);
      {Verifica se o espaço está vazio ou se o a peça escolhida é do jogador}
      if (valida_espaco(jogador, linha_atual,coluna_atual)) then 
      begin
         repeat
            writeln('Informe as coordenadas do espaço desejado');
            readln(linha, coluna);
         until (move_peca(jogador, linha_atual, coluna_atual, linha, coluna));
         inc(rodada);
         jogador := rodada mod 2;
         final := final_jogo(jogador);
         imprime_tabuleiro(jogador);
         delay(2000);
         clrscr;
      end;
   until (final); {XXX : informar jogador vencedor}
   
end.
