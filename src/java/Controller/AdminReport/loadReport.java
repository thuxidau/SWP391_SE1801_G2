package Controller.AdminReport;

import DAL.ReportDAO;
import Model.AccountLogin;
import Model.GoogleLogin;
import Model.Report;
import Model.Role;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.List;


public class loadReport extends HttpServlet {

    
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8"); 
        
        HttpSession session = request.getSession();
        AccountLogin user = (AccountLogin) session.getAttribute("account");
        GoogleLogin gguser = (GoogleLogin) session.getAttribute("gguser");
        
        if (user == null && gguser == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        Role role = (user != null) ? user.getUser().getRole() : gguser.getUser().getRole();
        int role2 = role.getID();
        
        if(role2 == 2){
            response.sendRedirect("login.jsp");
            return;
        }
        
        ReportDAO r = new ReportDAO();
        List<Report> list = r.selectAllReport();
        request.setAttribute("list", list);
        request.getRequestDispatcher("managereport.jsp").forward(request, response);
    }


    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }


    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }


    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
