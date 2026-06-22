/**
 * @description       : Methods for managing math operation
 * @author            : Christian Niro
 * @group             : 
 * @last modified on  : 05-15-2024
 * @last modified by  : 
**/
public class UtilsClassMath  extends Utils{
    //Generate alfanumeric String
    public static String writeUnique(){

        String uniqueCode = '';

        String characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'; // 62 ^ 18

        Integer charactersLength = characters.length();

        for (Integer i = 0; i < 18; i++){
            // this return string alfanumeric unique generate random
            Integer index = Integer.valueOf(Math.floor(Math.random() * charactersLength));
            uniqueCode += characters.substring(index, index + 1);
        }

        return uniqueCode;
    }

    //Method to convert Hex to Int
    public static Integer convertHexToInt(String hex){

        List<String> hexMap = new List<String>{ '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f' };

        Integer d0 = hexMap.IndexOf(hex.Substring(1, 2));
        Integer d1 = hexMap.IndexOf(hex.Substring(0, 1));

        Integer intval = d0 + (d1 * 16);
        return intval;
    }

    //Method to convert Int to Hex
    public static String convertIntToHex(Integer intval){

        List<String> hexMap = new List<String>{ '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f' };

        String hs0 = hexMap.Get(intval & 15); // i & 0x0f
        String hs1 = hexMap.Get(((intval >> 4) & 15)); //(i >> 4) & 0x0f
        return hs1 + hs0;
    }

    //Method to round a number to 5 decimal places
    public static String roundTo5DecimalPlaces(String input, Integer position){
        try{
            Decimal num = Decimal.valueOf(input);
            num = num.setScale(position, System.RoundingMode.HALF_UP);
            String roundedNumber = String.valueOf(num);
            return roundedNumber;
        } catch (Exception e){
            return 'Errore: Input non valido: il formato non è decimal';
        }
    }
}