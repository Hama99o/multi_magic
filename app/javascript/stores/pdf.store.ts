import { defineStore } from 'pinia';
import jsPDF from 'jspdf';
import html2canvas from 'html2canvas';

export const usePdfStore = defineStore({
  id: 'pdf-store',
  state: () => ({}),
  getters: {},
  actions: {
    async generatePdf(id) {
      const content = document.getElementById(id);

      if (!content) return;

      // Capture the HTML content as an image using html2canvas
      const canvas = await html2canvas(content, {
        scale: 2, // Higher quality
        useCORS: true, // Allows cross-origin images if needed
      });

      const imgData = canvas.toDataURL('image/png');
      const imgWidth = 210; // A4 width in mm
      const pageHeight = 297; // A4 height in mm
      const imgHeight = (canvas.height * imgWidth) / canvas.width;
      let heightLeft = imgHeight;
      const doc = new jsPDF('p', 'mm', 'a4');
      let position = 0;

      // Add the image to the first page
      doc.addImage(imgData, 'PNG', 0, position, imgWidth, imgHeight);
      heightLeft -= pageHeight;

      // Add more pages if content is larger than one page
      while (heightLeft > 0) {
        position = heightLeft - imgHeight;
        doc.addPage();
        doc.addImage(imgData, 'PNG', 0, position, imgWidth, imgHeight);
        heightLeft -= pageHeight;
      }

      // Download the PDF file
      doc.save('loan-application.pdf');
    }
  }
});
