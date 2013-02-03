ITEXT_JAVA=Rails.root.join('java_itext','itextpdf-5.3.5.jar').to_s

Rjb::load(ITEXT_JAVA)
$pdfreader=Rjb::import('com.itextpdf.text.pdf.PdfReader')
$pdfcopyfields=Rjb::import('com.itextpdf.text.pdf.PdfCopyFields')
$filestream = Rjb::import('java.io.FileOutputStream')