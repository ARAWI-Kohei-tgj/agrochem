module postgresql;

import dpq2: Connection;

enum DataBaseAccess: ubyte{
  readonly= 0x00,	// SELECT
  insert= 0x01,	// INSERT
  update= 0b0000_0010,	// UPDATE
  delete_= 0b0000_0100,	// DELETE
  truncate= 0b0000_1000	// truncate
}

/*************************************************************
 * Function getSeqLastVal
 *
 * sequenceの'last_value'を取得
 *************************************************************/
int getSeqLastValue(Connection conn, in string seqName) @system{
	import dpq2: QueryParams, as;
  @(DataBaseAccess.readonly) QueryParams cmdSerial= (){
    enum string QUERY_STR= `SELECT last_value
FROM `;
    QueryParams result;
    result.sqlCommand= QUERY_STR ~seqName ~';';
    return result;
  }();
  auto ans= conn.execParams(cmdSerial);
  return cast(int)(ans[0][0].as!long);
}
