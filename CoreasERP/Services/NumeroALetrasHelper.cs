namespace CoreasERP.Services;

public static class NumeroALetrasHelper
{
    public static string Convertir(decimal numero)
    {
        long entero = (long)Math.Truncate(numero);
        int centavos = (int)Math.Round((numero - entero) * 100, 0);

        string letrasEntero = NumeroALetras(entero);
        return $"{letrasEntero} CON {centavos:D2}/100 USD".ToUpper();
    }

    private static string NumeroALetras(long value)
    {
        if (value == 0) return "CERO DÓLARES";
        if (value == 1) return "UN DÓLAR";

        string res = ConvertirEntero(value);
        return $"{res} DÓLARES";
    }

    private static string ConvertirEntero(long value)
    {
        if (value == 0) return "CERO";
        if (value < 0) return "MENOS " + ConvertirEntero(-value);

        if (value <= 29)
        {
            return value switch
            {
                1 => "UN",
                2 => "DOS",
                3 => "TRES",
                4 => "CUATRO",
                5 => "CINCO",
                6 => "SEIS",
                7 => "SIETE",
                8 => "OCHO",
                9 => "NUEVE",
                10 => "DIEZ",
                11 => "ONCE",
                12 => "DOCE",
                13 => "TRECE",
                14 => "CATORCE",
                15 => "QUINCE",
                16 => "DIECISÉIS",
                17 => "DIECISIETE",
                18 => "DIECIOCHO",
                19 => "DIECINUEVE",
                20 => "VEINTE",
                21 => "VEINTIÚN",
                22 => "VEINTIDÓS",
                23 => "VEINTITRÉS",
                24 => "VEINTICUATRO",
                25 => "VEINTICINCO",
                26 => "VEINTISÉIS",
                27 => "VEINTISIETE",
                28 => "VEINTIOCHO",
                29 => "VEINTINUEVE",
                _ => ""
            };
        }

        if (value <= 99)
        {
            long d = (value / 10) * 10;
            long u = value % 10;
            string decenas = d switch
            {
                30 => "TREINTA",
                40 => "CUARENTA",
                50 => "CINCUENTA",
                60 => "SESENTA",
                70 => "SETENTA",
                80 => "OCHENTA",
                90 => "NOVENTA",
                _ => ""
            };
            return u > 0 ? $"{decenas} Y {ConvertirEntero(u)}" : decenas;
        }

        if (value <= 999)
        {
            if (value == 100) return "CIEN";
            long c = (value / 100) * 100;
            long r = value % 100;
            string centenas = c switch
            {
                100 => "CIENTO",
                200 => "DOSCIENTOS",
                300 => "TRESCIENTOS",
                400 => "CUATROCIENTOS",
                500 => "QUINIENTOS",
                600 => "SEISCIENTOS",
                700 => "SETECIENTOS",
                800 => "OCHOCIENTOS",
                900 => "NOVECIENTOS",
                _ => ""
            };
            return r > 0 ? $"{centenas} {ConvertirEntero(r)}" : centenas;
        }

        if (value <= 999999)
        {
            long miles = value / 1000;
            long r = value % 1000;
            string strMiles = (miles == 1) ? "MIL" : $"{ConvertirEntero(miles)} MIL";
            return r > 0 ? $"{strMiles} {ConvertirEntero(r)}" : strMiles;
        }

        if (value <= 999999999)
        {
            long millones = value / 1000000;
            long r = value % 1000000;
            string strMillones = (millones == 1) ? "UN MILLÓN" : $"{ConvertirEntero(millones)} MILLONES";
            return r > 0 ? $"{strMillones} {ConvertirEntero(r)}" : strMillones;
        }

        return value.ToString();
    }
}
