/**
  @description       : Function for open a Custom Confirm Modal
  @author            : Christian Niro
  @group             : Christian Niro
  @last modified on  : 05-14-2024
  @last modified by  : 
**/

export function openConfirm(options) {
    const modalTitle = options.modalTitle ;
    const modalMessage = options.modalMessage ;
    return new Promise((resolve) => {
        function handleCancel() {
            resolve(false);
            removeModal();
        }

        function handleConfirm() {
            resolve(true);
            removeModal();
        }

        function removeModal() {
            document.body.removeChild(modalContainer);
        }

        window.addEventListener('keyup', (event) => {
            if (event.key === 'Escape') {
                handleCancel();
            }
        });

        const modalContainer = document.createElement('div');
        modalContainer.setAttribute('class', 'custom-modal-container');

        const modalSection = document.createElement('section');
        modalSection.setAttribute('role', 'dialog');
        modalSection.setAttribute('tabindex', '-1');
        modalSection.setAttribute('class', 'slds-modal slds-fade-in-open');

        const modalDiv = document.createElement('div');
        modalDiv.setAttribute('class', 'slds-modal__container');

        const modalHeader = document.createElement('header');
        modalHeader.setAttribute('class', 'slds-modal__header slds-modal__header_empty');
        modalHeader.style.backgroundColor = '#c2003c';
        modalHeader.style.color = 'white';
        const headerText = document.createElement('h2');
        headerText.setAttribute('class', 'slds-text-heading_medium slds-hyphenate');
        headerText.textContent = modalTitle;
        modalHeader.appendChild(headerText);

        const modalContent = document.createElement('div');
        modalContent.setAttribute('class', 'slds-modal__content slds-p-around_medium');
        const contentText = document.createElement('p');
        contentText.textContent = modalMessage;
        modalContent.appendChild(contentText);

        const modalFooter = document.createElement('footer');
        modalFooter.setAttribute('class', 'slds-modal__footer');
        modalFooter.style.backgroundColor = '#606060';


        const cancelButton = document.createElement('button');
        cancelButton.setAttribute('class', 'slds-button slds-button_neutral');
        cancelButton.style.backgroundColor = '#c2003c';
        cancelButton.style.color = 'white';
        cancelButton.textContent = 'Annulla';
        cancelButton.addEventListener('click', handleCancel);

        const confirmButton = document.createElement('button');
        confirmButton.setAttribute('class', 'slds-button slds-button_brand');
        confirmButton.style.backgroundColor = '#c2003c';
        confirmButton.style.color = 'white';
        confirmButton.textContent = 'Conferma';
        confirmButton.addEventListener('click', handleConfirm);

        modalFooter.appendChild(cancelButton);
        modalFooter.appendChild(confirmButton);

        modalDiv.appendChild(modalHeader);
        modalDiv.appendChild(modalContent);
        modalDiv.appendChild(modalFooter);

        modalSection.appendChild(modalDiv);

        modalContainer.appendChild(modalSection);

        const backdropDiv = document.createElement('div');
        backdropDiv.setAttribute('class', 'slds-backdrop slds-backdrop_open');

        modalContainer.appendChild(backdropDiv);

        document.body.appendChild(modalContainer);
    });
}