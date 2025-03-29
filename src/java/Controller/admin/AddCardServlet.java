package Controller.admin;

import DAL.ProductCardDAO;
import DAL.UserDAO;
import Model.AccountLogin;
import Model.GoogleLogin;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.logging.Level;
import java.util.logging.Logger;

@MultipartConfig
public class AddCardServlet extends HttpServlet {
    private final UserDAO udao = new UserDAO();
    private final ProductCardDAO pcdao = new ProductCardDAO();

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, ParseException {
        response.setContentType("text/html;charset=UTF-8");
        int pcid = Integer.parseInt(request.getParameter("pcid"));
        String seri = request.getParameter("seri");
        String code = request.getParameter("code");
        String expiredDate = request.getParameter("expireddate");
        
        HttpSession session = request.getSession();
        AccountLogin user = (AccountLogin) session.getAttribute("account");
        GoogleLogin gguser = (GoogleLogin) session.getAttribute("gguser");

        if (user == null && gguser == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int userid = (user != null) ? user.getUser().getID() : gguser.getUser().getID();
        
        if(!udao.checkAdmin(userid)){
            response.sendRedirect("login.jsp");
            return;
        }

        boolean hasError = false;
        String errorMessage = "";

        // Validate seri length
        if (seri.length() != 16) {
            errorMessage = "Seri phải chứa 16 ký tự.";
            hasError = true;
        } else if (code.length() != 16) {  // Validate code length
            errorMessage = "Code phải chứa 16 ký tự.";
            hasError = true;
        } else {
            // Validate expired date
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            try {
                Date expired_date = sdf.parse(expiredDate);

                // Get the start of today
                Calendar cal = Calendar.getInstance();
                cal.set(Calendar.HOUR_OF_DAY, 0);
                cal.set(Calendar.MINUTE, 0);
                cal.set(Calendar.SECOND, 0);
                cal.set(Calendar.MILLISECOND, 0);
                Date todayStart = cal.getTime();

                if (expired_date.before(todayStart)) {
                    errorMessage = "Ngày hết hạn không được là ngày trong quá khứ.";
                    hasError = true;
                } 
            } catch (ParseException e) {
                errorMessage = "Ngày hết hạn không hợp lệ.";
                hasError = true;
            }
        }

        if (hasError) {
            request.setAttribute("error", errorMessage);
            request.getRequestDispatcher("productcard?pcid=" + pcid).forward(request, response);
            return;
        }

        // Check if seri already exists
        if (pcdao.checkSeriExist(seri, -1)) {
            request.setAttribute("error", "Seri đã tồn tại.");
            request.getRequestDispatcher("productcard?pcid=" + pcid).forward(request, response);
            // Check if code already exists
        } else {
            // Update the card if all checks pass
            pcdao.addCard(pcid, seri, code, expiredDate, userid);
            request.setAttribute("success", "Thẻ đã được thêm thành công.");
            request.getRequestDispatcher("productcard?pcid=" + pcid).forward(request, response);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            processRequest(request, response);
        } catch (ParseException ex) {
            Logger.getLogger(AddCardServlet.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            processRequest(request, response);
        } catch (ParseException ex) {
            Logger.getLogger(AddCardServlet.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    @Override
    public String getServletInfo() {
        return "Short description";
    }
}