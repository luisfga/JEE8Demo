package com.luisfga.jsf;

import com.luisfga.business.LoginUseCase;
import com.luisfga.business.exceptions.PendingEmailConfirmationException;
import com.luisfga.business.helper.MailHelper;
import java.io.UnsupportedEncodingException;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.ejb.EJB;
import javax.enterprise.context.RequestScoped;
import javax.faces.application.FacesMessage;
import javax.faces.context.FacesContext;
import javax.inject.Named;
import javax.mail.MessagingException;
import javax.security.auth.login.LoginException;
import javax.servlet.ServletContext;
import org.apache.shiro.authc.AuthenticationException;

@Named
@RequestScoped
public class Login{

    @EJB LoginUseCase loginUseCase;
    
    @EJB private MailHelper mailHelper;

    private String token;
    public String getToken() { return token; }
    public void setToken(String token) { this.token = token; }

    private String email;
    public String getEmail() {
        return email;
    }
    public void setEmail(String email) {
        this.email = email;
    }
    
    private String password;
    public String getPassword() {
        return password;
    }
    public void setPassword(String password) {
        this.password = password;
    }
    
    public String execute() {
        
        try {

            loginUseCase.login(email, password);
            
        } catch ( LoginException le) { 

            // Bring the information message using the Faces Context
            String errorMessage = FacesContext.getCurrentInstance().getApplication().
                    getResourceBundle(FacesContext.getCurrentInstance(),"msg").
                    getString("action.error.authentication.exception");
            
            // Add View Faces Message
            FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR,errorMessage, errorMessage);
            // The component id is null, so this message is considered as a view message
            FacesContext.getCurrentInstance().addMessage(null, message);
            // Return empty token for navigation handler

            return "login";
            
        } catch (PendingEmailConfirmationException pecException) {
            
            // Bring the information message using the Faces Context
            String errorMessage = FacesContext.getCurrentInstance().getApplication().
                    getResourceBundle(FacesContext.getCurrentInstance(),"msg").
                    getString("action.error.pending.email.confirmation");
            
            // Add View Faces Message
            FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR,errorMessage, errorMessage);
            // The component id is null, so this message is considered as a view message
            FacesContext.getCurrentInstance().addMessage(null, message);
            

            try {
                ServletContext ctx = (ServletContext) FacesContext.getCurrentInstance().getExternalContext().getContext();
                mailHelper.enviarEmailConfirmacaoNovoUsuario(ctx.getContextPath(),loginUseCase.loadUser(email));

            } catch (MessagingException | UnsupportedEncodingException ex) { //generaliza possíveis exceções em uma só
                Logger.getLogger(Login.class.getName()).log(Level.SEVERE, "Erro ao tentar enviar email de confirmação para o usuário {"+email+"}", ex);
//                addActionError(getText("exception.email.confirmation.sending"));

                // Bring the information message using the Faces Context
                String errorMessage2 = FacesContext.getCurrentInstance().getApplication().
                        getResourceBundle(FacesContext.getCurrentInstance(),"msg").
                        getString("exception.email.confirmation.sending");

                // Add View Faces Message
                FacesMessage message2 = new FacesMessage(FacesMessage.SEVERITY_ERROR,errorMessage2, errorMessage2);
                // The component id is null, so this message is considered as a view message
                FacesContext.getCurrentInstance().addMessage(null, message2);
            }
            
            return "login"; // Return empty token for navigation handler
            

            
        } catch (AuthenticationException authException) {

            String errorMessage = FacesContext.getCurrentInstance().getApplication().
                    getResourceBundle(FacesContext.getCurrentInstance(),"msg").
                    getString("action.error.authentication.exception");

            // Add View Faces Message
            FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR,errorMessage, errorMessage);
            // The component id is null, so this message is considered as a view message
            FacesContext.getCurrentInstance().addMessage(null, message);

            return "login";  
        }
        
        return "/secure/dashboard?faces-redirect=true";
    }
}
