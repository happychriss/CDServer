import java.io.*;
import com.itextpdf.text.*;
import com.itextpdf.text.pdf.*;

public class MergePDF {  

public static String combine (String path1, String path2)
{
    File file1 = new File(path1);
    File file2 = new File(file1, path2);
    return file2.getPath();
}
     public static void main(String[] args){
        try {
          String[] files = args;
	      String tempDir = System.getProperty("java.io.tmpdir");
	      String combined_doc=combine(tempDir,"CombinedPDFDocument.pdf");
          Document PDFCombineUsingJava = new Document();
          PdfCopy copy = new PdfCopy(PDFCombineUsingJava, new FileOutputStream(combined_doc));
          PDFCombineUsingJava.open();
          PdfReader ReadInputPDF;
          int number_of_pages;

          for (int i = 0; i < files.length; i++) {
                  ReadInputPDF = new PdfReader(files[i]);
                  number_of_pages = ReadInputPDF.getNumberOfPages();
                  for (int page = 0; page < number_of_pages; ) {
                          copy.addPage(copy.getImportedPage(ReadInputPDF, ++page));
                        }
          }
          PDFCombineUsingJava.close();
        }
        catch (Exception i)
        {
            System.out.println(i);
        }
    }
}
