using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data.Entity.Core;
using System.Collections;
using System.Data;
using System.Data.SqlClient;

namespace ISEL {
    public class AppEF {
        

        private SqlConnection con;
        private SqlTransaction tran;
        private enum Option {
            Unknown = -1,
            Exit,
            InsertLicitation,
            RemoveLicitation,
            FinishAuction,
            FinishDirectSail,
            LicitationValue,
            LastLicitations,
            Ports,
            UncompletedActions,
            CheckPassword,
            ExportXml
        }
        private static AppEF __instance;
        private AppEF()
        {
            __dbMethods = new Dictionary<Option, DBMethod>();
            __dbMethods.Add(Option.InsertLicitation, InsertLicitation);
            __dbMethods.Add(Option.RemoveLicitation, RemoveLicitation);
            __dbMethods.Add(Option.FinishAuction, FinishAuction);
            __dbMethods.Add(Option.FinishDirectSail, FinishDirectSail);
            __dbMethods.Add(Option.LicitationValue, LicitationValue);
            __dbMethods.Add(Option.LastLicitations, LastLicitations);
            __dbMethods.Add(Option.Ports, Ports);
            __dbMethods.Add(Option.UncompletedActions, UncompletedActions);
            __dbMethods.Add(Option.CheckPassword, CheckPassword);
            __dbMethods.Add(Option.ExportXml, XmlConverter.ExportXml);
        }
        public static AppEF Instance
        {
            get
            {
                if (__instance == null)
                    __instance = new AppEF();
                return __instance;
            }
            private set { }
        }

        private Option DisplayMenu()
        {
            Option option = Option.Unknown;
            try
            {
                Console.WriteLine("Escolha uma opcao:");
                Console.WriteLine();
                Console.WriteLine("1. Inserir uma licitacao");
                Console.WriteLine("2. Retirar uma licitacao");
                Console.WriteLine("3. Concluir a compra de um leilao");
                Console.WriteLine("4. Realizar a compra de um artigo de venda directa");
                Console.WriteLine("5. Determinar o valor da licitacao de um artigo");
                Console.WriteLine("6. Obter as n ultimas licitacoes");
                Console.WriteLine("7. Obter os portes, dadas duas localizacoes;");
                Console.WriteLine("8. Listar os leiloes que nao foram concluidos;");
                Console.WriteLine("9. Verificar a password de um utilizador");
                Console.WriteLine("10. Export xml");
                Console.WriteLine("0. Sair da aplicacao");
                var result = Console.ReadLine();
                option = (Option)Enum.Parse(typeof(Option), result);
            }
            catch (ArgumentException ex)
            {
                //nothing to do. User press select no option and press enter.
            }
            return option;
        }

        private Utils.Credentials getCredentials()
        {
            Console.Write("user: ");
            string username = Console.ReadLine();
            string password = "";
            Console.Write("password: ");

            ConsoleKeyInfo key;

            do
            {
                key = Console.ReadKey(true);

                if (key.Key != ConsoleKey.Backspace && key.Key != ConsoleKey.Enter)
                {
                    password += key.KeyChar;
                    Console.Write("*");
                }
                else
                {
                    if (key.Key == ConsoleKey.Backspace && password.Length > 0)
                    {
                        password = password.Substring(0, (password.Length - 1));
                        Console.Write("\b \b");
                    }
                }
            }
            while (key.Key != ConsoleKey.Enter);
            Console.WriteLine();
            return new Utils.Credentials(username, password);
        }

        Utils.Credentials cr = null;
        private void Login()
        {
            using (var ctx = new ISELEntities2())
            {
                bool check = false;
                Exception ex;
                do
                {
                    ex = null;
                    cr = getCredentials();
                    try
                    {
                        con = new SqlConnection();
                        con.ConnectionString = @"Data Source=.;Initial Catalog=ISEL;"
                                                + "User Id="+cr.Username+";Password="+cr.Password+";";
                        con.Open();
                    }
                    catch (Exception e)
                    {
                        Console.WriteLine("Introduza novamente os campos");
                        ex = e;
                    }
                    finally
                    {
                        if (con != null) con.Close();
                        if (ex == null) check = true;
                    }
                } while (!check);
            }
        }

        private delegate void DBMethod();
        private System.Collections.Generic.Dictionary<Option, DBMethod> __dbMethods;

        public void Run()
        {
            Console.Clear();
            Login();
                Option userInput = Option.Unknown;
                do
                {
                    Console.Clear();
                    userInput = DisplayMenu();
                    Console.Clear();
                    try
                    {
                        __dbMethods[userInput]();
                    }
                    catch (KeyNotFoundException ex)
                    {
                        continue;
                    }
                } while (userInput != Option.Exit);
            
        }

        //verifica a existencia do utilizador
        private bool CheckUser(string user)
        {
            using (var ctx = new ISELEntities2())
            {
                Utilizador util = null;                
                util = ctx.Utilizador.FirstOrDefault((utilizador) => utilizador.email == user);
                if (util == null)
                {
                    Console.WriteLine("Nome de utilizador incorreto!");
                    return false;
                }
                Console.WriteLine("Nome de utilizador correto!");
                return true;
            }
        }

        //verifica a existencia do artigo
        private bool CheckItem(int artigoId)
        {
            using (var ctx = new ISELEntities2())
            {
                Artigo art = null;
                //unCheck=1
                art = ctx.Artigo.FirstOrDefault((artigo) => artigo.id == artigoId && artigo.unCheck==true);
                return (art != null);
            }
        }
        //todo
        //artigos de leilao
        private List<int> AuctionItem()
        {
            List<int> leiloes = new List<int>();
            List<int?> compras = new List<int?>();
            List<int> ids = new List<int>();
            using (var ctx = new ISELEntities2())
            {
                leiloes = ctx.Leilao
                    .Select((leilao) => leilao.artigoId)
                    .ToList();
                compras = ctx.Compra.Select((c)=>c.artigoId).ToList();

                ids = ctx.Artigo
                    .Where((artigo)=>artigo.unCheck == true)
                    .Select((artigo) => artigo.id)
                    .Where((id) => leiloes.Contains(id))
                    .Where((id) => !compras.Contains(id))
                    .ToList();
            }
            if (ids.Count > 0)
            {
                Console.Write("Artigos disponiveis em Leilao: ");
                foreach (int id in ids)
                    Console.Write(id + " ");
                Console.WriteLine();
            }
            return ids;                        
        }
        //todo
        //artigos de venda direta
        private List<int> DirectSellingItem()
        {
            List<int> vendaDire = new List<int>();
            List<int?> compras = new List<int?>();
            List<int> ids = new List<int>();
            using (var ctx = new ISELEntities2())
            {
                vendaDire = ctx.VendaDirecta
                    .Select((venda) => venda.artigoId)
                    .ToList();
                compras = ctx.Compra.Select((comp)=>comp.artigoId).ToList();
                ids = ctx.Artigo
                    .Where((artigo) => artigo.unCheck == true)
                    .Select((artigo) => artigo.id)
                    .Where((id) => vendaDire.Contains(id))
                    .Where((id) => !compras.Contains(id))
                    .ToList();
            }
            if (ids.Count > 0)
            {
                Console.Write("Artigos disponiveis em Venda Direta: ");
                foreach (int id in ids)
                    Console.Write(id + " ");
                Console.WriteLine();
            }
            return ids;
        }

        //informacao de um artigo
        private void GetInfoItem(int id, string table)
        {            
            using (var ctx = new ISELEntities2())
            {
                if (table.Equals("Leilao"))
                {
                    Leilao art = ctx.Leilao.FirstOrDefault((artigo) => artigo.artigoId == id);
                    Console.Write("Informacao do artigo: ");
                    Console.WriteLine("artigoId: " + id + " licitacaoMin: " + art.licitacaoMin + 
                        " valorMin: " + art.valorMin);
                }
                else
                {
                    VendaDirecta art = ctx.VendaDirecta.FirstOrDefault((artigo) => artigo.artigoId == id);
                    Console.Write("Informacao do artigo: ");
                    Console.WriteLine("artigoId: " + id + " licitacaoMin: " + art.precoVenda);
                }
            //cmd.CommandText = "select * from " + table + " where artigoId=" + id + " and artigoId not in (select artigoId from dbo.Compra)";
            }
            Console.WriteLine();
        }

        // verificar se o artigo é válido e apresenta a sua info
        private int AskForItemAndInfo()
        {
            int artigoId = 0;
            bool result = false, artigoValido = false;
            List<int> leilao = AuctionItem();
            List<int> venda = DirectSellingItem();
            if (leilao.Count < 1 && venda.Count < 1)
                return -1;
            while (!artigoValido)
            {
                while (!result)
                {
                    Console.WriteLine("Indique qual o artigo a licitar/verificar:");
                    string art = Console.ReadLine();
                    result = Int32.TryParse(art, out artigoId);
                }
                if (!leilao.Contains(artigoId) && !venda.Contains(artigoId))
                {
                    //nao foi comprado mas ja foi licitado    
                    Console.WriteLine("Artigo indisponível");
                    artigoValido = false;
                    result = false;
                }
                else artigoValido = true;
            }
            GetInfoItem(artigoId, leilao.Contains(artigoId) ? "Leilao" : "VendaDirecta");
            return artigoId;
        }

        // pedir um email
        private string AskForEmail()
        {
            string email = "";
            bool emailValido = false;
            while (!emailValido)
            {
                Console.WriteLine("Indique o seu email:");
                email = Console.ReadLine();
                emailValido = CheckUser(email);
            }
            return email;
        }
      

        /*---------------------------------------------------------------------------------------------------------*/
        // DONE e
        private void InsertLicitation()
        {
            Console.WriteLine("(e) Inserir uma licitação;");
            string user = AskForEmail();
            int artigoId = AskForItemAndInfo();
            if (artigoId == -1)
            {
                Console.WriteLine("Nao existem mais artigos");
                Console.Read();
                return;
            }
            decimal preco = 0;
            bool result = false;
            while (!result)
            {
                Console.WriteLine("Indique o valor que deseja licitar:");
                string p = Console.ReadLine();
                result = Decimal.TryParse(p, out preco);
            }
            DateTime data = Utils.GetDateFormatDate();
            using (var ctx = new ISELEntities2())
            {
                try
                {
                    ctx.inserirLicitacao(data, preco, user, artigoId);
                    ctx.SaveChanges();
                } 
                catch(DataException e)
                { 
                    Console.Write(e.InnerException.Message);
                    Console.Read();
                    return;
                }                       
            }
            Console.WriteLine("Licitacao efetuada com sucesso!");
            Console.Read();
        }
        // DONE f
        private void RemoveLicitation()
        {
            bool sLicit = false;
            Console.WriteLine("(f) Retirar uma licitação;");
            string user = AskForEmail();
            int artigoId = AskForItemAndInfo();
            if (artigoId == -1)
            {
                Console.WriteLine("Nao existem mais artigos");
                Console.Read();
                return;
            }
            using (var ctx = new ISELEntities2())
            {
                try
                {
                    ctx.removerLicitacao(user, artigoId);
                    ctx.SaveChanges();
                }
                catch (DataException e)
                {
                    Console.Write(e.InnerException.Message);
                    Console.Read();
                    return;
                }
            }
            VerifyRemoveLicitation(artigoId, user);
            Console.Read();
        }
        private void VerifyRemoveLicitation(int artigoId, string user)
        {
            using (var ctx = new ISELEntities2())
            {
                Licitacao licit = null;
                licit = ctx.Licitacao
                    //.Where((data) => data.dataHora. == max(data) )
                    .FirstOrDefault((licitacao) => licitacao.artigoId == artigoId && licitacao.unCheck == false && licitacao.email == user);
                if (licit != null) Console.WriteLine("Remocao com sucesso!");
                else Console.WriteLine("Erro na remocao!");
            }
        }
        // todo g
        private void FinishAuction()
        {
            Console.WriteLine("(g) Concluir a compra de um leilão;");
            List<int> auctions = AuctionItem();
            if (auctions.Count < 1)
            {
                Console.WriteLine("Nao existem artigos em leilao para compra");
                Console.Read();
                return;
            }
            int artigoId = Utils.AskForItem(auctions);
            Console.WriteLine("Insira o local de destino:");
            string local = Console.ReadLine();
            int cartao = Utils.AskForCreditCard();
            DateTime data = Utils.GetDateFormatDate();
            using (var ctx = new ISELEntities2())
            {
                try
                {
                    ctx.efetuarLeilao(data, local, cartao, artigoId);
                    ctx.SaveChanges();
                }
                catch (DataException e)
                {
                    Console.Write(e.InnerException.Message);
                    VerifyFinishAuction(artigoId);
                }
            }
            Console.Read();
        }
        private void VerifyFinishAuction(int artigoId)
        {
            using (var ctx = new ISELEntities2())
            {
                Artigo art = null;
                art = ctx.Artigo.FirstOrDefault((artigo) => artigo.id == artigoId && artigo.unCheck == false);
                if (art != null) Console.WriteLine("Leilao concluido com sucesso!");
            }
        }
        // todo h
        private void FinishDirectSail()
        {
            Console.WriteLine("(h) Realizar a compra de um artigo de venda directa;");
            List<int> sail = DirectSellingItem();
            if (sail.Count < 1)
            {
                Console.WriteLine("Nao existem artigos em venda direta para compra");
                Console.Read();
                return;
            }
            int artigoId = Utils.AskForItem(sail);
            Console.WriteLine("Insira o local de destino:");
            string local = Console.ReadLine();
            int cartao = Utils.AskForCreditCard();
            DateTime data = Utils.GetDateFormatDate();
            using (var ctx = new ISELEntities2())
            {
                try
                {
                    ctx.efetuarCompraDireta(data, local, cartao, artigoId);
                    ctx.SaveChanges();
                }
                catch (DataException e)
                {
                    
                    Console.Write(e.InnerException.Message);
                    VerifyFinishDirectSail(artigoId);
                }
            }
            Console.Read();
        }
        private void VerifyFinishDirectSail(int artigoId)
        {
            using (var ctx = new ISELEntities2())
            {
                Artigo art = null;
                art = ctx.Artigo.FirstOrDefault((artigo) => artigo.id == artigoId && artigo.unCheck == false);
                if (art != null) Console.WriteLine("Venda direta concluida com sucesso!");
            }
        }
        // DONE i
        private void LicitationValue()
        {
            Console.WriteLine("(i) Determinar o valor da licitação de um artigo;");
            int artigoId = AskForItemAndInfo();
            if (artigoId == -1)
            {
                Console.WriteLine("Nao existem mais artigos");
                Console.Read();
                return;
            }
            using (var ctx = new ISELEntities2())
            {
                var result = from t in ctx.valorLicit(artigoId)
                             select t;
                foreach (var t in result)
                {
                    Console.WriteLine("artigo: {0}, email: {1}, data/hora: {2}, preco: {3} euro(s)",
                        t.artigoId, t.email, t.dataHora, t.preco);
                }
            }
            Console.Read();
        }
        // DONE j
        private void LastLicitations()
        {
            Console.WriteLine("(j) Obter as n últimas licitações;");
            int n = 0;
            bool result = false;
            while (!result && n < 1)
            {
                Console.WriteLine("Indique quantas licitacoes pretende ver:");
                string p = Console.ReadLine();
                result = Int32.TryParse(p, out n);
            }
            using (var ctx = new ISELEntities2())
            {
                var resul = from t in ctx.nLicitacao(n)
                             select t;
                foreach (var t in resul)
                {
                    Console.WriteLine("artigo: {0}, email: {1}, data/hora: {2}, preco: {3} euro(s)",
                        t.artigoId, t.email, t.dataHora, t.preco);
                }
            }
            Console.Read();
        }
        // DONE k
        private void Ports()
        {
            Console.WriteLine("(k) Obter os portes, dadas duas localizações;");
            string orig, dest;
            Console.WriteLine("Indique o local de origem:");
            orig = Console.ReadLine();
            Console.WriteLine("Indique o local de destino:");
            dest = Console.ReadLine();
            System.Data.Entity.Core.Objects.ObjectParameter valorPorte = 
                new System.Data.Entity.Core.Objects.ObjectParameter("valorPorte", typeof(int));

            using (var ctx = new ISELEntities2())
            {
                ctx.valuePorte(orig, dest, valorPorte);
                
            }
            if (!valorPorte.Value.ToString().Equals(""))
                Console.WriteLine("Valor do porte entre " + orig + " e " + dest + " é de " + valorPorte.Value + " euro(s)");
            else
                Console.WriteLine("Locais inválidos");
            Console.Read();
        }
        // DONE l
        private void UncompletedActions()
        {
            Console.WriteLine("(l) Listar os leilies nao concluídos;");
            List<int> artigos = new List<int>();
            using (var ctx = new ISELEntities2())
            {
                var resul = from t in ctx.leilaoNaoConcluido
                            select t;
                foreach (var t in resul)
                {
                    Console.WriteLine("Licitacao com o id " + t.lid);
                    artigos.Add(t.lid);
                }
            }
            List<Venda> leiloes = new List<Venda>();
            using (var ctx = new ISELEntities2())
            {
                leiloes = ctx.Venda
                    .Where((leilao) => artigos.Contains(leilao.artigoId))
                    .ToList();                   
            }
            foreach (Venda l in leiloes)
                Console.WriteLine("artigoId: " + l.artigoId + ", email: " + l.email +
                                ", data de inicio: " + l.dataInicio + ", data de fim: " + l.dataFim +
                                ", local de origem: " + l.localOrigem + ", condicao: " + l.condicao + 
                                ", descricao: " + l.descricao);
            Console.Read();
        }
        // DONE m
        private void CheckPassword()
        {
            Console.WriteLine("(m) Verificar a password de um utilizador; ");
            Utils.Credentials cred = getCredentials();
            System.Data.Entity.Core.Objects.ObjectParameter res =
                new System.Data.Entity.Core.Objects.ObjectParameter("res", typeof(int));
            using (var ctx = new ISELEntities2())
            {
                try
                {
                    ctx.verificarPp(cred.Username, cred.Password,res);
                }catch(Exception e)
                {
                    Console.Write(e.Message);
                }
            }
            if (res.Value.ToString().Equals("0")) 
                    Console.WriteLine("Palavra passe correta!");
            else
                Console.WriteLine("Palavra passe incorreta!");           
            Console.Read();
        }

        public static void Ef()
        {
            AppEF.Instance.Run();
        }

    }
}


