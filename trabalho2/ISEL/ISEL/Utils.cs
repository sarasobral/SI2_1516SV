using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ISEL {
    class Utils {
        //retorna a data numa string
        public static string GetDate()
        {
            int year = DateTime.Now.Year;
            int month = DateTime.Now.Month;
            int day = DateTime.Now.Day;
            int hour = DateTime.Now.Hour;
            int minute = DateTime.Now.Minute;
            int second = DateTime.Now.Second;
            return year + "-" + month + "-" + day + " " + hour + ":" + minute + ":" + second;
        }
        public static DateTime GetDateFormatDate()
        {
            DateTime myDateTime = DateTime.Now;
            string sqlFormattedDate = myDateTime.ToString("yyyy-MM-dd HH:mm:ss");
            return myDateTime;
        }
        
        public static int AskForCreditCard()
        {
            int cartao = 0;
            while (cartao == 0)
            {
                Console.WriteLine("Insira o seu cartao de credito:");
                string card = Console.ReadLine();
                Int32.TryParse(card, out cartao);
            }
            return cartao;
        }

        public static int AskForItem(List<int> itens)
        {
            int artigoId = 0;
            while (!itens.Contains(artigoId))
            {
                Console.WriteLine("Indique qual o artigo:");
                string art = Console.ReadLine();
                Int32.TryParse(art, out artigoId);
            }
            return artigoId;
        }

        public class Credentials {
            public string Username
            {
                get;
                private set;
            }
            public string Password
            {
                get;
                private set;
            }
            public Credentials(string username, string password)
            {
                Username = username;
                Password = password;
            }
        }



    }
}
