class NetUtil 
{
  final static String url = "http://pixelddc.com/";
  public String message = "";
  
  public NetUtil() {}
  
  void saveImage(String title, String folder, int mode) {
    println("-- SAVING PNG START");
    save("tmp.png");
    postData(title+"-"+year()+nf(month(),2)+nf(day(),2)+"-"+nf(hour(),2)+nf(minute(),2)+nf(second(),2)+"-"+frameCount%100,
      "png",
      folder,
      loadBytes("tmp.png"), 
      mode);
    println("-- SAVING PNG STOP");
  }
  
  void postData(String title, String ext, String folder, byte[] bytes, int mode) {
    try{
      URL u = new URL(url+"saveFile.php?title="+title+"&ext="+ext+"&folder="+folder+"&mode="+mode);
      URLConnection c = u.openConnection();
      // post multipart data
   
      c.setDoOutput(true);
      c.setDoInput(true);
      c.setUseCaches(false);
   
      // set request headers
      c.setRequestProperty("Content-Type", "multipart/form-data; boundary=AXi93A");
   
      // open a stream which can write to the url
      DataOutputStream dstream = new DataOutputStream(c.getOutputStream());
   
      // write content to the server, begin with the tag that says a content element is comming
      dstream.writeBytes("--AXi93A\r\n");
   
      // discribe the content
      dstream.writeBytes("Content-Disposition: form-data; name=\"data\"; filename=\"whatever\" \r\nContent-Type: image/png\r\nContent-Transfer-Encoding: binary\r\n\r\n");
      dstream.write(bytes,0,bytes.length);
   
      // close the multipart form request
      dstream.writeBytes("\r\n--AXi93A--\r\n\r\n");
      dstream.flush();
      dstream.close();
   
      // read the output from the URL
      try{
        BufferedReader in = new BufferedReader(new InputStreamReader(c.getInputStream()));
        String sIn = in.readLine();
        boolean b = true;
        while(sIn!=null){
          if(sIn!=null){
            System.out.println(sIn);
            this.message = sIn;
          }
          sIn = in.readLine();
        }
      }
      catch(Exception e){
        e.printStackTrace();
      }
    }
   
    catch(Exception e){ 
      e.printStackTrace();
    }
  }

}
