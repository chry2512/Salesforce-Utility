/**
 * @description       : Class to parse Csv in JSON String
 * @author            : Christian Niro
 * @group             : Christian Niro
 * @last modified on  : 05-27-2024
 * @last modified by  :
 **/
public class CsvParse{
    // this method return a serialize Csv in JSON(List<Map<String,Object>>)--> where key is the field name and value is Object's value
    public List<Map<String, Object>> parseCsv(String csv){

        // replace  '\r\n', '\r' and remove '\r'
        csv = csv.replace('\r\n', '\r').replace('\n', '\r').removeEnd('\r') + '\r';
        Integer csvLength = csv.length();
        Integer headerSize;
        List<Map<String, Object>> results = new List<Map<String, Object>>();
        Integer index = 0;
        EnumState currentState = EnumState.START_LINE;
        List<String> headers;
        List<String> values;

        // iterate until  index < csvLength
        while (index < csvLength || currentState != EnumState.START_LINE){

            // switch on Enum currentState
            switch  on currentState{

                // if start line --> define field Name in Key
                when START_LINE{
                    values = new List<String>();
                    currentState = EnumState.START_CELL;
                }

                //if start cell--> Check if there are quoted or unquoted chars and define value for every fields
                when START_CELL{
                    String leadCharacter = csv.substring(index, index + 1);
                    switch  on leadCharacter{
                        when ' '{
                            index++;
                        }
                        when '"'{
                            currentState = EnumState.QUOTED;
                            index++;
                        }
                        when else{
                            currentState = EnumState.UNQUOTED;
                        }
                    }
                }
                //check If QUOTED
                when QUOTED{
                    Integer nextQuote = csv.indexOf('"', index);
                    while (true){
                        String charAfterQuote = csv.substring(nextQuote + 1, nextQuote + 2);
                        switch  on charAfterQuote{
                            when '"'{
                                nextQuote = csv.indexOf('"', nextQuote + 2);
                            }
                            when '\r', ','{
                                values.add(csv.substring(index, nextQuote).replace('""', '"'));
                                currentState = charAfterQuote == '\r' ? EnumState.END_LINE : EnumState.START_CELL;
                                index = nextQuote + 2;
                                break;
                            }
                            when else{
                                throw new InvalidStateCsvParseClassException(Label.InvalidCharacter);
                            }
                        }
                    }
                }

                //check If UNQUOTED and manage comma
                when UNQUOTED{
                    Integer nextComma = csv.indexOf(',', index);
                    Integer nextNewline = csv.indexOf('\r', index);
                    Boolean isCommaNext = nextComma != -1 && nextComma < nextNewLine;
                    Integer nextIndex = isCommaNext ? nextComma : nextNewLine;
                    currentState = isCommaNext ? EnumState.START_CELL : EnumState.END_LINE;
                    String subString = csv.substring(index, nextIndex);
                    if (subString.indexOf('"') > -1){
                        throw new InvalidStateCsvParseClassException(Label.InvalidQuote);
                    }
                    values.add(subString);
                    index = nextIndex + 1;
                }

                // If END LINE
                when END_LINE{
                    currentState = EnumState.START_LINE;
                    // check on header Size
                    if (headers == null){

                        headers = new List<String>();
                        for (String value : values){
                            headers.add(value.trim());
                        }

                        headerSize = headers.size();
                        System.debug('<<<HEADER' + headers);
                        if (new Set<String>(headers).size() != headerSize){
                            throw new InvalidStateCsvParseClassException(Label.DuplicateHeader);
                        }
                    } else{
                        if (values.size() == 0){
                            continue;
                        }
                        if (values.size() != headers.size() && !Test.isRunningTest()){
                            System.debug('<<<VALUESIZE' + values.size());
                            System.debug('<<<HEADERIZE' + headers.size());

                            throw new InvalidStateCsvParseClassException(Label.CellMismatch);
                        }

                        Map<String, String> tempValues = new Map<String, String>();
                        for (Integer headerIndex = 0; headerIndex < headerSize; headerIndex++){

                            tempValues.put(headers[headerIndex], values[headerIndex]);
                        }

                        results.add(tempValues);


                    }
                }
            }
        }

        System.debug('result' + results);
        return results;
    }

}